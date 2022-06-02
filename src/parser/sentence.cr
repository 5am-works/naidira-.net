require "../word"
require "./words"

DICTIONARY = Dictionary.load

struct Sentence
  property predicate : Predicate?
  property argument1 : Argument?
  property argument2 : Argument?
  property argument3 : Argument?

  def validate_and_return
    if predicate.nil? && argument1.nil? && argument2.nil? && argument3.nil?
      raise "Empty sentence"
    end

    self
  end
end

def parse(sentence : String)
  words = sentence.split
  next_index = 0
  sentence = Sentence.new

  words.each do |input_word|
    word = DICTIONARY.find input_word
    if word.nil?
      raise "Unrecognized word: #{input_word}"
    elsif word.is_a? Verb
      sentence.predicate = Predicate.new word
    elsif word.is_a? Particle
      if word.postfix?
        VERB_PARTICLES[input_word]?.try do |verb_p|
          predicate = sentence.predicate
          if predicate.nil?
            raise "Read verb modifier #{input_word}, but no verb present"
          end

          verb_p.call(predicate)
        end
      else
        raise "TODO: Prefix particles"
      end
    elsif word.is_a? Noun
      raise "TODO: Noun"
    else
      raise "Can't process #{word.spelling}"
    end

    next_index += 1
  end

  {sentence.validate_and_return, words[next_index..]}
end