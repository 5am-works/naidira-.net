module Naidira.Core.Tests.LexiconTests

open NUnit.Framework
open Naidira.Core
open Naidira.Core.Lexicon

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
