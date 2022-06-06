require "../Dictionary"
require "../word"
require "./words"

DICTIONARY = Dictionary.load

struct Sentence
  property predicate : Predicate?
  property arguments : Array(Argument?)

  def initialize(@predicate, @arguments)
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

  def add_argument(noun : Noun)
    @last_read_argument = @arguments[@next_argument] = Argument.new noun
    @next_argument += 1
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
        puts "Particle parsed"
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