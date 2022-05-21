enum WordType
  Noun
  Adjective
  Verb0
  Verb1
  Verb2
  Verb3
  PrefixModifier
  PostfixModifier
  PrefixParticle
  PostfixParticle

  def modifier?
    self == PrefixModifier || self == PostfixModifier
  end
end

class Word
  property spelling : String
  property type : WordType
  property simple_meaning : String
  property formatted_meaning : String | Nil

  def initialize(@spelling, @type, @simple_meaning, @formatted_meaning = nil)
  end

  def to_entry
    "#{spelling}|#{type.value}|#{simple_meaning}|#{formatted_meaning || ""}"
  end

  def pp
    "#{spelling} (#{type}): #{simple_meaning}"
  end
end

class Modifier < Word
  property modifiable_types : Set(WordType)
  property attachment_types : Array(WordType)
  property attachment_notes : Array(String | Nil)

  def initialize(@spelling, @type, @simple_meaning, @formatted_meaning, @modifiable_types, @attachment_types, @attachment_notes)
  end

  def to_entry
    "#{super.to_entry}|#{modifiable_types.map(&.value).join(',')}|#{attachment_types.map(&.value).join(',')}|#{attachment_notes.join('^')}"
  end
end
