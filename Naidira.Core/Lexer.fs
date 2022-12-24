module Naidira.Core.Lexer

open System.Collections.Generic
open System.Text.RegularExpressions
open Naidira.Core.Lexicon
open Naidira.Core.Utils

type LModifier = Modifier

type Mood =
   | Imperative
   | Optative
   | Potential
   | Indicative

type Tense =
   | Complete
   | Incomplete

type WordAttribute = | Personal

type Argument =
   { BaseWords: Set<Noun>
     Modifiers: Set<Modifier>
     Attributes: Set<WordAttribute> }

and Predicate =
   { BaseWord: Verb
     Mood: Mood
     Tense: Tense
     Modifiers: Set<Modifier>
     Negated: bool }

and Modifier =
   { BaseWord: LModifier
     Attachments: Attachment list }

and Attachment =
   | ArgumentAttachment of Argument
   | PredicateAttachment of Predicate

type Constituent =
   | ArgumentConstituent of Argument
   | PredicateConstituent of Predicate
   | ModifierConstituent of Modifier

type LexerResult = Constituent list

type ArgumentBuilder =
   { BaseWords: HashSet<Noun>
     Modifiers: HashSet<ModifierBuilder>
     Attributes: HashSet<WordAttribute> }

and PredicateBuilder =
   { BaseWord: Verb
     mutable Mood: Mood }

and ModifierBuilder =
   { BaseWord: LModifier
     Attachments: LinkedList<Attachment> }

type ConstituentBuilder =
   | Argument of ArgumentBuilder
   | Predicate of PredicateBuilder

type LexerState =
   { Constituents: LinkedList<ConstituentBuilder>
     ReadingModifier: ModifierBuilder option
     mutable LastReadArgument: ArgumentBuilder option
     mutable LastReadPredicate: PredicateBuilder option
     WaitingParticles: LinkedList<Particle> }

let private whitespaceRegex = Regex(@"\s+")

let private processVerbParticle
   (particle: Particle)
   (lexerState: LexerState)
   : Result<unit, string> =
   failwith "TODO"

let private processNounParticle
   (particle: Particle)
   (lexerState: LexerState)
   : Result<unit, string> =
   failwith "TODO"

let private processNoun (noun: Noun) lexerState =
   match lexerState.LastReadArgument with
   | Some argument ->
      argument.BaseWords.Add(noun) |> ignore
      Ok lexerState
   | None ->
      let argument =
         { BaseWords = HashSet([ noun ])
           Modifiers = HashSet()
           Attributes = HashSet() }

      lexerState.Constituents.AddLast(Argument argument) |> ignore
      lexerState.LastReadArgument <- Some argument
      lexerState.LastReadPredicate <- None
      Ok lexerState

let private processVerb (verb: Verb) lexerState =
   let predicate =
      { BaseWord = verb
        Mood = Indicative }
   lexerState.Constituents.AddLast(Predicate predicate) |> ignore
   lexerState.LastReadArgument <- None
   lexerState.LastReadPredicate <- Some predicate
   Ok lexerState

let private processParticle (particle: Particle) lexerState =
   let result =
      match particle with
      | :? PrefixParticle as prefixParticle ->
         lexerState.WaitingParticles.AddLast(prefixParticle) |> ignore |> Ok
      | :? PostfixParticle as postfixParticle ->
         processVerbParticle postfixParticle lexerState
         |> altResult (fun _ -> processNounParticle postfixParticle lexerState)
      | _ -> failwith "Unreachable"

   result
   |> Result.map (fun () ->
      lexerState.LastReadArgument <- None
      lexerState)

let private processWord (lexicon: Lexicon) lexerState word =
   match lexicon.Lookup(word) with
   | Some lemma ->
      match lemma with
      | :? Noun as noun -> processNoun noun lexerState
      | :? Verb as verb -> processVerb verb lexerState
      | :? Particle as particle -> processParticle particle lexerState
      | _ -> failwith $"TODO: process {lemma.Spelling}"
   | None -> Error $"Word not found: {word}"

let buildModifier (mb: ModifierBuilder) : Modifier =
   { BaseWord = mb.BaseWord
     Attachments = List.ofSeq mb.Attachments }

let buildArgument (ab: ArgumentBuilder) : Argument =
   { BaseWords = Set.ofSeq ab.BaseWords
     Modifiers = Set.ofSeq (Seq.map buildModifier ab.Modifiers)
     Attributes = Set.ofSeq ab.Attributes }

let buildPredicate (pb: PredicateBuilder) : Predicate =
   { BaseWord = pb.BaseWord
     Mood = Indicative
     Tense = Incomplete
     Modifiers = Set.empty
     Negated = false }

let toLexerResult (lexerState: LexerState) : Result<LexerResult, string> =
   if lexerState.WaitingParticles.Count > 0 then
      Error $"Unused modifiers: {lexerState.WaitingParticles}"
   else
      lexerState.Constituents
      |> Seq.map (fun cb ->
         match cb with
         | Argument argument -> ArgumentConstituent(buildArgument argument)
         | Predicate predicate -> PredicateConstituent(buildPredicate predicate))
      |> List.ofSeq
      |> Ok

let lexicalize (lexicon: Lexicon) (input: string) =
   let words = whitespaceRegex.Split(input)

   let state =
      { Constituents = LinkedList()
        ReadingModifier = None
        LastReadArgument = None
        LastReadPredicate = None
        WaitingParticles = LinkedList() }

   foldResult (processWord lexicon) state words |> Result.bind toLexerResult
