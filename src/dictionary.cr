require "baked_file_system"
require "./word"

DICTIONARY_FILE = "#{__DIR__}/data/words"

class Dictionary
  extend BakedFileSystem

  property words = Hash(String, Word).new

  bake_folder "./data"

  def initialize
    lines = if File.exists? DICTIONARY_FILE
      File.new(DICTIONARY_FILE).each_line
    else
      Dictionary.get("words").each_line
    end
    @words = lines.map do |line|
      parts = line.split '|'
      spelling = parts[0]
      word_type = WordType.new parts[1].to_i
      simple_meaning = parts[2]
      formatted_meaning = parts[3].empty? ? nil : parts[3]

      if word_type.modifier?
        modifiable_types = parts[4].split(',').map(&.to_i).map(&->WordType.new(Int32)).to_set
        attachment_types = parts[5].split(',').map(&.to_i).map(&->WordType.new(Int32))
        attachment_notes = parts[6].split('^').map do |note|
          note.empty? ? nil : note
        end
        Modifier.new spelling, word_type, simple_meaning, formatted_meaning,
          modifiable_types, attachment_types, attachment_notes
      else
        Word.new spelling, word_type, simple_meaning, formatted_meaning
      end
    end.to_h do |word|
      {word.spelling, word}
    end
  end

  def find(word)
    words[word]?
  end

  def add(word)
    words[word.spelling] = word
  end

  def save(filename = "#{__DIR__}/data/words")
    File.open(filename, "w") do |file|
      words.values.sort_by(&.spelling).each do |word|
        file.puts word.to_entry
      end
    end
  end
end
