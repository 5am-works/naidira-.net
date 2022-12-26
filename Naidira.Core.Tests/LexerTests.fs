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
      let input = "levi ti bome vile ki tuiri"
      let expected = [ ar "levi"; pri "bome"; ar "vile"; pr "ki"; ar "tuiri" ]
      this.TestLexer input expected

   [<Test>]
   member this.TestPredicateAndArgument2() =
      let input = "mailomi gemi rita senai li kena boli vi"
      let expected =
         [ ar "mailomi"
           prp "gemi"
           pro "senai"
           arsp [ "kena"; "boli" ] ]
      this.TestLexer input expected
      
   [<Test>]
   member this.TestPredicateAndArgument3() =
      let input = "pelora ta luna beti"
      let expected =
         [ pri "pelora"
           ars [ "luna"; "beti" ] ]
      this.TestLexer input expected

   member private this.TestLexer input expected =
      let result = Lexer.lexicalize this.lexicon input

      match result with
      | Ok lexerResult -> Assert.That(lexerResult, Is.EqualTo(expected))
      | Error error -> Assert.Fail(error)
