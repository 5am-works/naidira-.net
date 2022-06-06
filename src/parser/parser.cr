require "./sentence"

class Parser
  property words : Array(String)

  def initialize(@words)
    @sentences = [] of Sentence
    @sentence = SentenceBuilder.new
  end

  def parse!
    @words.each do |input_word|
      word = DICTIONARY.find input_word
      if word.nil?
        raise "Unrecognized word: #{input_word}"
      end
      parse word
    end

    @sentences << @sentence.build
  end

  private def parse(verb : Verb)
    unless @sentence.add_predicate verb
      @sentences << @sentence.build
      @sentence = SentenceBuilder.new
      @sentence.add_predicate verb
    end
  end

  private def parse(particle : Particle)
    @sentence.add_particle particle
  end

  private def parse(noun : Noun)
    @sentence.add_argument noun
  end

  private def parse(word)
    raise "Can't process #{word.spelling}"
  end
end

def parse(sentence : String)
  words = sentence.split
  parser = Parser.new words
  parser.parse!
end