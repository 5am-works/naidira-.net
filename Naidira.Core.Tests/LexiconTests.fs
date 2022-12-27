module Naidira.Core.Tests.LexiconTests

open System
open System.Collections.Generic
open NUnit.Framework
open Naidira.Core
open Naidira.Core.Lexicon

type MutableList<'a> = List<'a>

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

   [<Test>]
   member this.TestMeaningLength() =
      let failingWords = MutableList()
      for word in this.lexicon.Index.Values do
         if word.SimpleMeaning.Length > 30 then
            failingWords.Add(word.Spelling)
      
      if failingWords.Count > 0 then
         let wordList = String.Join(", ", failingWords)
         Assert.Fail($"Simple meaning strings too long: {wordList}")