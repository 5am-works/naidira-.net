require "spec"
require "../src/naidira"

def v(verb : String, mood : Mood?)
  verb_entry = DICTIONARY.find(verb).not_nil!

  unless verb_entry.is_a? Verb
    raise "Not a verb: #{verb}"
  end

  predicate = Predicate.new verb_entry
  predicate.mood = mood
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