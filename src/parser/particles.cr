require "./words"

enum Mood
  Imperative
end

alias VerbParticleHandler = Predicate -> Nil

VERB_PARTICLES = {
  "ta" => ->(p: Predicate) do
    p.mood = Mood::Imperative
  end
}