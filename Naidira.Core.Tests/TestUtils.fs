module Naidira.Core.Tests.TestUtils

open Naidira.Core
open Naidira.Core.Lexer
open Naidira.Core.Lexicon

let private lexicon = LexiconLoader.lexiconInstance.Value

let pr (word: string): Constituent =
   let baseWord = lexicon.Get word :?> Verb
   { BaseWord = baseWord
     Mood = Indicative
     Tense = Incomplete
     Modifiers = Set.empty
     Negated = false }
   |> PredicateConstituent
   
let pri (word: string): Constituent =
   let baseWord = lexicon.Get word :?> Verb
   { BaseWord = baseWord
     Mood = Imperative
     Tense = Incomplete
     Modifiers = Set.empty
     Negated = false }
   |> PredicateConstituent
  
let ar (word: string): Constituent =
   let baseWord = lexicon.Get word :?> Noun
   { Argument.BaseWords = Set.singleton baseWord
     Modifiers = Set.empty
     Attributes = Set.empty }
   |> ArgumentConstituent

let prp (word: string): Constituent =
   let baseWord = lexicon.Get word :?> Verb
   { BaseWord = baseWord
     Mood = Indicative
     Tense = Complete
     Modifiers = Set.empty
     Negated = false }
   |> PredicateConstituent

let pro (word: string): Constituent =
   let baseWord = lexicon.Get word :?> Verb
   { BaseWord = baseWord
     Mood = Optative
     Tense = Incomplete
     Modifiers = Set.empty
     Negated = false }
   |> PredicateConstituent
   
let private ars_ (words: string list): Argument =
   let baseWords = List.map (fun word -> lexicon.Get word :?> Noun) words
   { Argument.BaseWords = Set.ofList baseWords
     Modifiers = Set.empty
     Attributes = Set.empty }
   
let ars (words: string list): Constituent =
   ars_ words
   |> ArgumentConstituent

let arsp (words: string list): Constituent =
   let argument = ars_ words
   { argument with Attributes = Set.singleton Personal }
   |> ArgumentConstituent