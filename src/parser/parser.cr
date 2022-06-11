require "./sentence"
require "./lexer"

include Naidira::Lexicon

module Naidira::Parser
  alias LModifier = Naidira::Lexicon::Modifier

  class Parser
    property words : Iterator(Constituent)
    @reading_partial_sentence : SentenceBuilder?
    @last_read : Predicate | Argument | Nil

    def initialize(words)
      @words = words.each
      @sentences = [] of Sentence
      @sentence = SentenceBuilder.new
      @waiting_modifiers = Deque(Modifier).new
      @reading_partial_sentence = nil
      @reading_modifier = nil
    end

    def parse!
      next_word = next_word!
      if next_word.nil?
        unless @reading_partial_sentence.nil?
          ps = @reading_partial_sentence.not_nil!
          if ps.empty?
            raise "Did not read sentence for #{@reading_modifier}"
          else
            rm = @reading_modifier.not_nil!
            rm.add_attachment ps.build
            lr = @last_read
            if !lr.nil? && rm.can_modify? lr
              lr.add_modifier rm
            else
              raise "#{rm} cannot modify #{lr}"
            end
          end
        end
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
      unless @reading_partial_sentence.nil?
        ps = @reading_partial_sentence.not_nil!
        if ps.add_predicate predicate
          return
        else
          @reading_modifier.not_nil!.add_attachment ps.build
          @reading_partial_sentence = nil
        end
      end

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
      @last_read = predicate
    end

    private def parse(argument : Argument)
      @sentence.add_argument argument
      @last_read = argument
    end

    private def parse(modifier : Modifier)
      if modifier.prefix?
        @waiting_modifiers << modifier
      elsif modifier.is? "si"
        @reading_modifier = modifier
        read_partial_sentence omit: 0
      elsif modifier.modifies_verbs?
        predicate = @sentence.predicate || raise "#{modifier} needs a verb"
        predicate.add_modifier modifier
      end
    end

    private def read_partial_sentence(*, omit : Int)
      @reading_partial_sentence = SentenceBuilder.new omit
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
    self.parse constituents
  end

  def self.parse(constituents : Iterable(Constituent))
    parser = Parser.new constituents
    parser.parse!
  end
end
