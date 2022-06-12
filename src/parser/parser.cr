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
      @waiting_particles = Deque(Particle).new
      @fix_next_argument = nil
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
      unless @waiting_particles.empty?
        @waiting_particles.each do |particle|
          VERB_PARTICLES[particle.spelling]?.try do |p|
            p.call @sentence, predicate
            true
          end || raise "#{particle} cannot be attached to a verb (#{predicate})" 
        end
        @waiting_particles.clear
      end

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
      unless @waiting_particles.empty?
        @waiting_particles.each do |particle|
          NOUN_PARTICLES[particle.spelling]?.try do |p|
            p.call @sentence, argument
            true
          end || raise "#{particle} needs a noun" 
        end
        @waiting_particles.clear
      end

      unless @waiting_modifiers.empty?
        @waiting_modifiers.each do |modifier|
          if modifier.can_modify? argument
            argument.add_modifier modifier
          else
            raise "#{modifier} cannot modify #{argument}"
          end
        end
        @waiting_modifiers.clear
      end

      unless @fix_next_argument.nil?
        next_argument = @fix_next_argument.not_nil!
        unless @sentence.fix_argument next_argument, argument
          @sentences << @sentence.build
          @sentence = SentenceBuilder.new
          @sentence.fix_argument next_argument, argument
        end 
        @fix_next_argument = nil
      else
        unless @sentence.add_argument argument
          @sentences << @sentence.build
          @sentence = SentenceBuilder.new
          @sentence.add_argument argument
        end
      end

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

    private def parse(particle : Particle)
      if particle.is? "ne"
        @fix_next_argument = 0
      elsif particle.prefix?
        @waiting_particles << particle
      else
        VERB_PARTICLES[particle.spelling]?.try do |v_particle|
          predicate = @sentence.predicate || raise "#{particle.spelling} needs a verb"
          v_particle.call @sentence, predicate.as(Predicate)
          true
        end || NOUN_PARTICLES[particle.spelling]?.try do |n_particle|
          argument = @last_read.is_a?(Argument) ? @last_read.as Argument :
            raise "#{particle.spelling} needs a noun"
          n_particle.call @sentence, argument.as(Argument)
        end || raise "Unrecognized particle: #{particle.spelling}"
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
