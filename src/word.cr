require "json"
include JSON

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

  def verb?
    self == Verb0 || self == Verb1 || self == Verb2 || self == Verb3
  end
end

class Word
  include JSON::Serializable
  use_json_discriminator "type", {
    noun: Noun,
    adjective: Noun,
    verb0: Verb,
    verb1: Verb,
    verb2: Verb,
    verb3: Verb,
    prefix_modifier: Modifier,
    postfix_modifier: Modifier,
    prefix_particle: Particle,
    postfix_particle: Particle
  }

  property spelling : String
  property type : WordType
  property simple_meaning : String

  def initialize(@spelling, @type, @simple_meaning)
  end

  def pp
    "#{spelling} (#{type}, word): #{simple_meaning}"
  end
end

class Modifier < Word
  include JSON::Serializable
  property modifiable_types : Set(WordType)
  property attachment_types : Array(WordType)
  property attachment_notes : Array(String | Nil)

  def initialize(@spelling, @type, @simple_meaning, @modifiable_types, @attachment_types, @attachment_notes)
  end

  def pp
    "#{spelling} (#{type}, modifier): #{simple_meaning}"
  end
end

class Noun < Word
  def pp
    "#{spelling} (#{type}, noun): #{simple_meaning}"
  end
end

class Verb < Word
  include JSON::Serializable
  property formatted_meaning : String

  def initialize(@spelling, @type, @simple_meaning, @formatted_meaning)
  end

  def pp
    "#{spelling} (#{type}, verb): #{simple_meaning}"
  end

  def valency
    raise "TODO"
  end
end

class Particle < Word
  def prefix?
    type == WordType::PrefixParticle
  end

  def postfix?
    type == WordType::PostfixParticle
  end
end