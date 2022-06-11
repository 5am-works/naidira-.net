require "./constituent"

module Naidira::Parser
  class Lexer
    @words : Array(String)
    @constituents : Deque(Constituent)
    @reading_modifier : Modifier?
    @last_read_argument : Argument?

    def initialize(@words : Array(String))
      @constituents = Deque(Constituent).new
    end

    def run
      @words.each do |word|
        lemma = DICTIONARY.find(word) || raise "Word not found: #{word}"
        process lemma
      end
      
      unless @reading_modifier.nil?
        @constituents << @reading_modifier.not_nil!
      end
      @constituents.to_a
    end

    private def process(noun : Noun)
      unless @last_read_argument.nil?
        @last_read_argument.not_nil!.add_adjective noun
        return
      end

      argument = Argument.new noun

      if waiting_for_argument?
        add_to_modifier argument
      else
        @constituents << argument
      end
      @last_read_argument = argument
    end

    private def process(verb : Verb)
      predicate = Predicate.new verb

      unless @reading_modifier.nil?
        if waiting_for_predicate?
          add_to_modifier predicate
        else
          raise "Read #{verb}, but it is not compatible with #{@reading_modifier}"
        end
      else
        @constituents << predicate
        @last_read_argument = nil
      end
    end

    private def process(lmodifier : LModifier)
      modifier = Modifier.new lmodifier
      if lmodifier.prefix? && lmodifier.single_nounlike_attachment?
        last_argument = @constituents.pop? || raise "#{lmodifier.spelling} needs an attachment"
        unless last_argument.is_a? Argument
          raise "#{lmodifier.spelling} needs an argument, but found #{last_argument}"
        end

        modifier.add_attachment last_argument
        @constituents << modifier
      elsif lmodifier.has_attachments? && !lmodifier.sentence_attachment?
        @reading_modifier = modifier
      else
        @constituents << modifier
      end
      @last_read_argument = nil
    end

    private def process(particle : Particle)
      if particle.prefix?
        raise "TODO: Process prefix particle #{particle.spelling}"
      else
        VERB_PARTICLES[particle.spelling]?.try do |v_particle|
          predicate = @constituents.last? || raise "#{particle.spelling} needs a verb"
          v_particle.call predicate.as(Predicate)
          true
        end || NOUN_PARTICLES[particle.spelling]?.try do |n_particle|
          argument = @constituents.last? || raise "#{particle.spelling} needs a noun"
          n_particle.call argument.as(Argument)
        end || raise "Unrecognized particle: #{particle.spelling}"
      end
      @last_read_argument = nil
    end

    private def process(word)
      raise "TODO: Process #{word.spelling}"
    end

    private def waiting_for_argument?
      @reading_modifier.try(&.waiting_for? WordKind::Nounlike)
    end

    private def waiting_for_predicate?
      @reading_modifier.try(&.waiting_for? WordKind::Verblike)
    end

    private def add_to_modifier(attachment)
      modifier = @reading_modifier.not_nil!
      modifier.add_attachment attachment
      if modifier.complete?
        @constituents << modifier
        @reading_modifier = nil
      end
    end
  end

  def self.lexicalize(words)
    Lexer.new(words).run
  end
end
