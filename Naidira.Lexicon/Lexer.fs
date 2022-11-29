module Naidira.Lexicon.Lexer

open System.Collections.Generic
open System.Text.RegularExpressions
open Naidira.Lexicon.Lexicon
open Naidira.Lexicon.Utils

type LexerResult = Constituent list

type ArgumentBuilder =
   { BaseWords : HashSet<Noun>
     Modifiers : HashSet<ModifierBuilder>
     Attributes : HashSet<WordAttribute> }

type LexerState =
   { Constituents : ConstituentBuilder list
     ReadingModifier : ModifierBuilder option
     LastReadArgument : ArgumentBuilder option
     WaitingParticles : ParticleBuilder list }

let private whitespaceRegex = Regex(@"\s+")

let private processWord (lexicon: Lexicon) lexerState word =
   match lexicon.Lookup(word) with
   | Some lemma ->
      match lemma with
      | :? Noun -> failwith "TODO: process noun"
      | _ -> failwith $"TODO: process {lemma.Spelling}"
   | None -> Error $"Word not found: {word}"

let toLexerResult lexerState = failwith "TODO"

let lexicalize (lexicon: Lexicon) (input: string) =
   let words = whitespaceRegex.Split(input)
   let state =
      { Constituents = []
        ReadingModifier = None
        LastReadArgument = None
        WaitingParticles = [] }
   foldResult (processWord lexicon) state words
   |> Result.map toLexerResult