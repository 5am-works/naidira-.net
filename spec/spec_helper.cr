require "spec"
require "../src/naidira"

include Naidira::Parser

def v(verb : String)
  verb_entry = DICTIONARY.find(verb).not_nil!

  unless verb_entry.is_a? Verb
    raise "Not a verb: #{verb}"
  end

  Predicate.new verb_entry
end

def v!(verb : String)
  predicate = v verb
  predicate.mood = Mood::Imperative
  predicate
end

def n(noun : String)
  entry = DICTIONARY.find(noun).not_nil!
  unless entry.is_a? Noun
    raise "Not a noun: #{noun}"
  end

  Argument.new entry
end

def s(predicate : Predicate, arguments : Array(Argument?))
  Sentence.new predicate, arguments
end