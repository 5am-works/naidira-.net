require "../word"
require "./particles"

include Naidira::Lexicon
alias LModifier = Naidira::Lexicon::Modifier

module Naidira::Parser
  class Predicate
    property base_word : Verb
    property mood : Mood?

    def initialize(@base_word, @mood = nil)
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

  class Modifier
    property base_word : LModifier
    property attachments : Array(Argument)

    def initialize(@base_word, @attachments = [] of Argument)
    end

    def ==(other : Argument)
      base_word == other.base_word && attachments == other.attachments
    end
  end
end