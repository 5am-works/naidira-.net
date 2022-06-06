require "./words"

include Naidira::Lexicon

module Naidira::Parser
  enum Mood
    Imperative
  end

  VERB_PARTICLES = {
    "ta" => ->(s: SentenceBuilder, p: Predicate) do
      p.mood = Mood::Imperative
      s.imperative!
    end
  }
end