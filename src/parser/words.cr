require "../word"
require "./particles"

struct Predicate
  property base_word : Verb
  property mood : Mood?

  def initialize(@base_word)
  end
end

struct Argument
  property base_word : Noun

  def initialize(@base_word)
  end
end