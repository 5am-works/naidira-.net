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
  property simple_meaninng : String
  property formatted_meaning : String | Nil

  def initialize(@spelling, @type, @simple_meaninng, @formatted_meaning = nil)
  end
end

class Modifier < Word
  property modifiable_types : Set(WordType)
  property attachment_types : Array(WordType)
  property attachment_notes : Array(String | Nil)

  def initialize(@spelling, @type, @simple_meaninng, @formatted_meaning, @modifiable_types, @attachment_types, @attachment_notes)
  end
end
