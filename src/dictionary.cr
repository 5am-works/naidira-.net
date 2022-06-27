require "baked_file_system"
require "json"
require "./word"

module Naidira::Lexicon
  class Dictionary
    extend BakedFileSystem
    include JSON::Serializable
    @@DICTIONARY_FILE = "#{__DIR__}/data/words.json"

    property words = Hash(String, Word).new

    bake_folder "./data"

    def self.load
      input_file = if File.exists? @@DICTIONARY_FILE
                     File.new(@@DICTIONARY_FILE)
                   else
                     Dictionary.get("words.json")
                   end

      Dictionary.from_json(input_file)
    end

    def find(word : String)
      words[word]?
    end

    def search(query : String)
      words.each_value.select do |word|
        word.spelling.includes?(query) || word.simple_meaning.includes?(query)
      end
    end

    def sources
      words.values.map do |word|
        word.first_appearance
      end.reject(&.nil?).uniq.to_a
    end

    def each
      words.values.each do |word|
        yield word
      end
    end

    def alphabetical
      words.values.sort do |a, b|
        a.spelling <=> b.spelling
      end
    end

    def add(word)
      words[word.spelling] = word
    end

    def save(filename = @@DICTIONARY_FILE)
      File.open(filename, "w") do |file|
        to_pretty_json(file)
      end
    end
  end
end
