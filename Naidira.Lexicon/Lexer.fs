module Naidira.Lexicon.Lexer

open System.Collections.Generic
open System.Text.RegularExpressions
open Naidira.Lexicon.Lexicon
open Naidira.Lexicon.Utils

type LModifier = Modifier

type Mood =
   | Imperative
   | Optative
   | Potential
   | Indicative
   
type Tense =
   | Complete
   | Incomplete

type WordAttribute =
   | Personal

type Argument =
   { BaseWords : Set<Noun>
     Modifiers : Set<Modifier>
     Attributes : Set<WordAttribute> }

and Predicate =
   { BaseWord : Verb
     Mood : Mood
     Tense : Tense
     Modifiers : Set<Modifier>
     Negated : bool }

and Modifier =
   { BaseWord : LModifier
     Attachments : Attachment array }
   
and Attachment =
   | ArgumentAttachment of Argument
   | PredicateAttachment of Predicate

type Constituent =
   | ArgumentConstituent of Argument
   | PredicateConstituent of Predicate
   | ModifierConstituent of Modifier
   | ParticleConstituent of Particle

type LexerResult = Constituent list

type ArgumentBuilder =
   { BaseWords : HashSet<Noun>
     Modifiers : HashSet<ModifierBuilder>
     Attributes : HashSet<WordAttribute> }
   
and PredicateBuilder =
   { BaseWord: Verb }

and ModifierBuilder =
   { BaseWord : LModifier
     Attachments : Attachment array }
   
type ConstituentBuilder =
   | Argument of ArgumentBuilder
   | Predicate of PredicateBuilder

type LexerState =
   { Constituents : LinkedList<ConstituentBuilder>
     ReadingModifier : ModifierBuilder option
     mutable LastReadArgument : ArgumentBuilder option
     WaitingParticles : LinkedList<Particle> }

let private whitespaceRegex = Regex(@"\s+")

let private processNoun (noun: Noun) lexerState =
   match lexerState.LastReadArgument with
   | Some argument ->
      argument.BaseWords.Add(noun) |> ignore
      Ok lexerState
   | None ->
      let argument =
         { BaseWords = HashSet([noun])
           Modifiers = HashSet()
           Attributes = HashSet() }
      lexerState.Constituents.AddLast(Argument argument) |> ignore
      lexerState.LastReadArgument <- Some argument
      Ok lexerState
      
let private processVerb (verb: Verb) lexerState =
   let predicate =
      { BaseWord = verb }
   lexerState.Constituents.AddLast(Predicate predicate) |> ignore
   lexerState.LastReadArgument <- None
   Ok lexerState

let private processWord (lexicon: Lexicon) lexerState word =
   match lexicon.Lookup(word) with
   | Some lemma ->
      match lemma with
      | :? Noun as noun -> processNoun noun lexerState
      | :? Verb as verb -> processVerb verb lexerState
      | _ -> failwith $"TODO: process {lemma.Spelling}"
   | None -> Error $"Word not found: {word}"

let toLexerResult lexerState = failwith "TODO"

let lexicalize (lexicon: Lexicon) (input: string) =
   let words = whitespaceRegex.Split(input)
   let state =
      { Constituents = LinkedList()
        ReadingModifier = None
        LastReadArgument = None
        WaitingParticles = LinkedList() }
   foldResult (processWord lexicon) state words
   |> Result.map toLexerResult