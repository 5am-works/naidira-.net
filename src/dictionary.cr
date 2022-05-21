require "baked_file_system"
require "./word"

class Dictionary
  extend BakedFileSystem

  bake_folder "./data"

  def self.load
    lines = get("words").each_line
    lines.map do |line|
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
    end
  end
end