module Naidira.Lexicon.Tests.TestUtils

open Naidira.Lexicon
open Naidira.Lexicon.Lexer
open Naidira.Lexicon.Lexicon

let private lexicon = LexiconLoader.lexiconInstance.Value

let pr (word: string): Constituent =
   let baseWord = lexicon.Get word :?> Verb
   { BaseWord = baseWord
     Mood = Indicative
     Tense = Incomplete
     Modifiers = Set.empty
     Negated = false }
   |> PredicateConstituent

let pa (word: string): Constituent =
   lexicon.Get word :?> Particle
   |> ParticleConstituent
  
let ar (word: string): Constituent =
   let baseWord = lexicon.Get word :?> Noun
   { Argument.BaseWords = Set.ofList [ baseWord ]
     Modifiers = Set.empty
     Attributes = Set.empty }
   |> ArgumentConstituent