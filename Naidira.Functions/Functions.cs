using System.Collections.Generic;
using System.Linq;
using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Naidira.Core;
using Naidira.Interface;

namespace Naidira.Functions;

public static class Functions {
   private static readonly Lexicon.Lexicon Lexicon =
      LexiconLoader.lexiconInstance.Value;

   [Function("SearchFunction")]
   public static SearchResults Search(
      [HttpTrigger(AuthorizationLevel.Anonymous, "get",
         Route = "search/{query}")]
      HttpRequestData request,
      string query) {
      var results = Lexicon.Index.Values.Where(word =>
         word.Spelling.Contains(query) || word.SimpleMeaning.Contains(query)
      ).Select(word => new DictionaryEntry {
         Spelling = word.Spelling,
         WordType = word.WordType.ToString(),
         Meaning = word.SimpleMeaning
      });
      return new SearchResults {
         WordResults = results.ToList(),
      };
   }

   [Function("AlphabeticalListFunction")]
   public static List<Word> AlphabeticalList(
      [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "alphabetical")]
      HttpRequestData request) {
      return Lexicon.Index.Values.Select(word => new Word {
         Spelling = word.Spelling,
         SimpleMeaning = word.SimpleMeaning,
         Type = word.WordType.ToString(),
         FormattedMeaning = word is Lexicon.Verb v ? v.FormattedMeaning : null,
         AttachmentNotes =
            word is Lexicon.Modifier m
               ? m.AttachmentNotes.Select(str => str.ToNullable()).ToList()
               : null,
         AttachmentTypes =
            word is Lexicon.Modifier m2
               ? m2.AttachmentTypes.Select(t => t.ToString()).ToList()
               : null,
         ModifiableTypes =
            word is Lexicon.Modifier m3
               ? m3.ModifiableTypes.Select(t => t.ToString()).ToList()
               : null,
      }).ToList();
   }
}