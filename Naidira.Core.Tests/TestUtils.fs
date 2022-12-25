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
   { Argument.BaseWords = Set.ofList [ baseWord ]
     Modifiers = Set.empty
     Attributes = Set.empty }
   |> ArgumentConstituent