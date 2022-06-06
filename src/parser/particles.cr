require "./words"

enum Mood
  Imperative
end

alias VerbParticleHandler = (SentenceBuilder, Predicate) -> Nil

VERB_PARTICLES = {
  "ta" => ->(s: SentenceBuilder, p: Predicate) do
    p.mood = Mood::Imperative
    s.imperative!
  end
}