require "./constituent"

include Naidira::Lexicon

module Naidira::Parser
  enum Mood
    Imperative
  end

  VERB_PARTICLES = {
    "ta" => ->(p : Predicate) do
      p.mood = Mood::Imperative
    end,
  }
end
