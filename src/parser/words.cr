require "../word"
require "./particles"

class Predicate
  property base_word : Verb
  property mood : Mood?

  def initialize(@base_word)
  end

  def ==(other : Predicate)
    base_word == other.base_word && mood == other.mood
  end
end

class Argument
  property base_word : Noun

  def initialize(@base_word)
  end

  def ==(other : Argument)
    base_word == other.base_word
  end
end