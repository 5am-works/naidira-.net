require "./sentence"

include Naidira::Lexicon

module Naidira::Parser
  alias LModifier = Naidira::Lexicon::Modifier

  class Parser
    property words : Iterator(Constituent)

    def initialize(words)
      @words = words.each
      @sentences = [] of Sentence
      @sentence = SentenceBuilder.new
      @waiting_modifiers = Deque(Modifier).new
    end

    def parse!
      next_word = next_word!
      if next_word.nil?
        @sentences << @sentence.build
      else
        begin
          parse next_word
          parse!
        rescue exception
          puts "Error while parsing #{next_word}"
          raise exception
        end
      end
    end

    private def parse(predicate : Predicate)
      unless @waiting_modifiers.empty?
        @waiting_modifiers.each do |modifier|
          if modifier.can_modify? predicate
            predicate.add_modifier modifier
          else
            raise "#{modifier} cannot modify #{predicate}"
          end
        end
        @waiting_modifiers.clear
      end

      unless @sentence.add_predicate predicate
        @sentences << @sentence.build
        @sentence = SentenceBuilder.new
      end
      @sentence.add_predicate predicate
    end

    private def parse(argument : Argument)
      @sentence.add_argument argument
    end

    private def parse(modifier : Modifier)
      if modifier.prefix?
        @waiting_modifier = modifier
      else
        raise "TODO: Process #{modifier}"
      end
    end

    private def next_word!
      next_word = @words.next
      if next_word.is_a? Iterator::Stop
        nil
      else
        next_word
      end
    end
  end

  def self.parse(sentence : String)
    words = sentence.split
    constituents = Lexer.new(words).run
    parser = Parser.new constituents
    parser.parse!
  end
end
