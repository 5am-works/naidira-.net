require "./constituent"

include Naidira::Lexicon

module Naidira::Parser
  enum Mood
    Imperative
  end

  enum Attribute
    Personal
  end

  VERB_PARTICLES = {
    "ta" => ->(p : Predicate) do
      p.mood = Mood::Imperative
    end,
  }

  NOUN_PARTICLES = {
    "vi" => ->(a : Argument) do
      a.add_attribute Attribute::Personal
    end
  }
end
