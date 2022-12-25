using System.Text.Json.Serialization;

namespace Naidira.Client.Data; 

public class SearchResults {
   [JsonPropertyName("word_results")] public List<DictionaryEntry> WordResults { get; init; } = null!;
}

public class DictionaryEntry {
   [JsonPropertyName("spelling")] public string Spelling { get; set; } = "";
   [JsonPropertyName("word_type")] public string WordType { get; set; } = "";
   [JsonPropertyName("meaning")] public string Meaning { get; set; } = "";
}