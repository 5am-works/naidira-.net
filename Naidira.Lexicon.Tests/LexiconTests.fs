module Naidira.Lexicon.Tests.LexiconTests

open NUnit.Framework
open Naidira.Lexicon
open Naidira.Lexicon.Lexicon

[<TestFixture>]
type LexiconTests() =
   [<DefaultValue>]
   val mutable lexicon: Lexicon
   
   [<SetUp>]
   member this.Setup () =
      this.lexicon <- LexiconLoader.lexiconInstance.Value

   [<Test>]
   member this.TestLoad() =
      Assert.Pass("Words in dictionary: {0}", this.lexicon.WordCount)
