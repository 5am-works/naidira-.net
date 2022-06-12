require "../Dictionary"
require "../word"
require "./constituent"

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
    property fixed_arguments : Array(Bool)
    property omitted_argument : Int32?

    def initialize(@omitted_argument = nil)
      @arguments = Array(Argument | Nil).new(2) { nil }
      @fixed_arguments = Array(Bool).new(2) { false }
      @next_argument = if @omitted_argument.nil? || @omitted_argument == 1
        0
      else
        1
      end
      @waiting_verb_particles = Array(Particle).new
    end

    def add_predicate(predicate : Predicate)
      if @predicate.nil?
        @predicate = predicate
        if @next_argument > predicate.valency
          raise "#{predicate} has too many arguments"
        end
        if predicate.imperative? && no_arguments?
          @next_argument = 1
        end
        true
      else
        false
      end
    end

    def add_argument(argument : Argument)
      valency = predicate.try(&.valency)
      if !valency.nil? && @next_argument >= valency
        return false
      end
      @arguments[@next_argument] = argument
      @next_argument += 1
      true
    end

    def fix_argument(index : Int, argument : Argument)
      return false unless @arguments[index].nil?

      @arguments[index] = argument
      @fixed_arguments[index] = true
      @next_argument = index + 1
      true
    end

    def imperative!
      if !arguments[0].nil? && arguments[1].nil? && !fixed_arguments[0]
        arguments[1] = arguments[0]
        arguments[0] = nil
        @next_argument = 2
      end
    end

    def build
      if empty?
        raise "Empty sentence"
      end

      Sentence.new predicate, arguments
    end

    def empty?
      predicate.nil? && no_arguments?
    end

    private def no_arguments?
      arguments.all? &.nil?
    end
  end
end
