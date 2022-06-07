require "./sentence"

include Naidira::Lexicon

module Naidira::Parser
  alias LModifier = Naidira::Lexicon::Modifier

  class Parser
    property words : Iterator(String)

    def initialize(words)
      @words = words.each
      @sentences = [] of Sentence
      @sentence = SentenceBuilder.new
    end

    def parse!
      next_word = next_word!
      if next_word.nil?
        push_last_argument
        @sentences << @sentence.build
      else
        begin
          parse next_word
          parse!
        rescue exception
          puts "Error while parsing #{next_word.spelling}"
          raise exception
        end
      end
    end

    private def parse(verb : Verb)
      push_last_argument
      unless @sentence.add_predicate verb
        @sentences << @sentence.build
        @sentence = SentenceBuilder.new
        @sentence.add_predicate verb
      end
      @last_read_argument = nil
    end

    private def parse(particle : Particle)
      push_last_argument
      @sentence.add_particle particle
      @last_read_argument = nil
    end

    private def parse(noun : Noun)
      if @last_read_argument.nil?
        @last_read_argument = Argument.new noun
      else
        @last_read_argument.not_nil!.add_adjective noun
      end
    end

    private def parse(lmodifier : LModifier)
      modifier = Modifier.new lmodifier
      if lmodifier.prefix? && lmodifier.attachment_types.size == 1
        modifier.add_attachment(@last_read_argument || raise "#{lmodifier} needs an attachment")
        @last_read_argument = nil
      else
        push_last_argument
        lmodifier.attachment_types.each do |type|
          attachment = expect type
          word = case type
                 when WordKind::Nounlike
                   @last_read_argument = Argument.new attachment.as(Noun)
                 when WordKind::Verblike
                   Predicate.new attachment.as(Verb)
                 else
                   raise "TODO: #{type}"
                 end
          modifier.add_attachment word
        end
      end
      modifier
    end

    private def parse(word)
      raise "TODO: Process #{word.spelling}"
    end

    private def expect(word_kind : WordKind)
      word = next_word! || raise "Expected to read a word of #{word_kind}"
      unless word.has_kind? word_kind
        raise "Expected #{word} to have kind #{word_kind}"
      end

      word
    end

    private def next_word!
      next_word = @words.next
      if next_word.is_a? Iterator::Stop
        nil
      else
        word = DICTIONARY.find next_word
        if word.nil?
          raise "Unrecognized word: #{next_word}"
        end

        word
      end
    end

    private def push_last_argument
      unless @last_read_argument.nil?
        @sentence.add_argument @last_read_argument.not_nil!
        @last_read_argument = nil
      end
    end
  end

  def self.parse(sentence : String)
    words = sentence.split
    parser = Parser.new words
    parser.parse!
  end
end
