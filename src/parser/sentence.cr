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
    property omitted_argument : Int32?

    def initialize(@omitted_argument = nil)
      @arguments = Array(Argument | Nil).new(2) { nil }
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
        if predicate.imperative? && no_arguments?
          @next_argument = 1
        end
        true
      else
        false
      end
    end

    def add_argument(argument : Argument)
      @arguments[@next_argument] = argument
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
