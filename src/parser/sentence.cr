require "../Dictionary"
require "../word"
require "./words"

DICTIONARY = Dictionary.load

module Naidira::Parser
  struct Sentence
    property predicate : Predicate?
    property arguments : Array(Argument?)

    def initialize(@predicate, @arguments : Array(Argument?))
    end

    def inspect(io)
      predicate.inspect(io)
      io << "("
      io << arguments
      io << ")"
    end
  end

  class SentenceBuilder
    property predicate : Predicate?
    property arguments : Array(Argument?)

    def initialize
      @arguments = Array(Argument | Nil).new(3) { nil }
      @next_argument = 0
      @waiting_verb_particles = Array(Particle).new
    end

    def imperative!
      if no_arguments?
        @next_argument = 1
      end
    end

    def add_predicate(verb : Verb)
      if @predicate.nil?
        @predicate = Predicate.new verb
        true
      else
        false
      end
    end

    def add_argument(argument : Argument)
      @arguments[@next_argument] = argument
    end
    
    def build
      if predicate.nil? && no_arguments?
        raise "Empty sentence"
      end

      Sentence.new predicate, arguments
    end

    def add_particle(particle : Particle)
      VERB_PARTICLES[particle.spelling]?.try do |p|
        if particle.postfix?
          predicate = @predicate
          if predicate.nil?
            raise "Read verb particle #{particle}, but no verb present"
          end
          p.call(self, predicate)
        else
          @waiting_verb_particles << particle
        end
      end || raise "Cannot handle particle #{particle.spelling}"
    end

    private def no_arguments?
      arguments.all? &.nil?
    end
  end
end