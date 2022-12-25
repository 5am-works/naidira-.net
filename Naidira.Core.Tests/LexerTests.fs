module Naidira.Core.Tests.LexerTests

open NUnit.Framework
open Naidira.Core
open Naidira.Core.Lexicon

open TestUtils

[<TestFixture>]
type LexerTests() =
   [<DefaultValue>]
   val mutable lexicon: Lexicon
   
   [<SetUp>]
   member this.Setup() =
      this.lexicon <- LexiconLoader.lexiconInstance.Value
   
   [<Test>]
   member this.TestPredicateAndArgument() =
      let input = "levi ti bome"
      let expected =
         [ ar "levi"
           pri "bome" ]
      this.TestLexer input expected
      
   [<Test>]
   member this.TestPredicateAndArgument2() =
      let input = "vile ki tuiri"
      let expected =
         [ ar "vile"
           pr "ki"
           ar "tuiri" ]
      this.TestLexer input expected
   
   member private this.TestLexer input expected =
      let result = Lexer.lexicalize this.lexicon input
      match result with
      | Ok lexerResult -> Assert.That(lexerResult, Is.EqualTo(expected))
      | Error error -> Assert.Fail(error)