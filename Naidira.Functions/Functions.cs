using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Naidira.Core;
using Naidira.Interface;
using WordType = Naidira.Core.Lexicon.WordType;

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

   [Function("WordFunction")]
   public static async Task<HttpResponseData> GetWord([HttpTrigger(
         AuthorizationLevel.Anonymous, "get",
         Route = "word/{word}")]
      HttpRequestData request,
      string word
   ) {
      var result = Lexicon.Lookup(word).ToNullable();
      var response = request.CreateResponse();
      if (result is not null) {
         var wordResult = new Word {
            Spelling = result.Spelling,
            SimpleMeaning = result.SimpleMeaning,
            FullMeaning = result.Meaning,
            Type = result.WordType.Format(),
            FormattedMeaning = (result as Lexicon.Verb)?.FormattedMeaning,
            AttachmentNotes = (result as Lexicon.Modifier)?.AttachmentNotes
               .Select(str => str.ToNullable()).ToList(),
            AttachmentTypes = (result as Lexicon.Modifier)?.AttachmentTypes
               .Select(t => t.ToString()).ToList(),
            ModifiableTypes = (result as Lexicon.Modifier)?.ModifiableTypes
               .Select(t => t.ToString()).ToList(),
         };
         await response.WriteAsJsonAsync(wordResult);
      } else {
         response.StatusCode = HttpStatusCode.NotFound;
      }

      return response;
   }

   [Function("AlphabeticalListFunction")]
   public static List<DictionaryEntry> AlphabeticalList(
      [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "alphabetical")]
      HttpRequestData request) {
      return Lexicon.Index.Values.Select(word => new DictionaryEntry {
         Spelling = word.Spelling,
         Meaning = word.SimpleMeaning,
         WordType = word.WordType.ToString(),
      }).ToList();
   }

   private static string Format(this WordType wordType) {
      return wordType.Tag switch {
         WordType.Tags.Verb0 => "0-Verb",
         WordType.Tags.Verb1 => "1-Verb",
         WordType.Tags.Verb2 => "2-Verb",
         WordType.Tags.PostfixModifier => "Postfix modifier",
         WordType.Tags.PrefixModifier => "Prefix modifier",
         WordType.Tags.PostfixParticle => "Postfix particle",
         WordType.Tags.PrefixParticle => "Prefix particle",
         _ => wordType.ToString(),
      };
   }
}