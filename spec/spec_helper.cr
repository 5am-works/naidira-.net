require "spec"
require "../src/naidira"

include Naidira::Parser
include Naidira::Lexicon

def v(verb_entry : String, *modifiers)
  p = Predicate.new(verb(verb_entry))
  modifiers.each do |m|
    p.add_modifier m
  end
  p
end

def v!(verb : String, *modifiers)
  predicate = v verb, *modifiers
  predicate.mood = Mood::Imperative
  predicate
end

def n(noun : String, *adjectives)
  entry = DICTIONARY.find(noun).not_nil!.as(Noun)
  a = Argument.new entry
  adjectives.each do |m|
    adjective = DICTIONARY.find(m).not_nil!.as(Noun)
    a.add_adjective adjective
  end
  a
end

def m(modifier : String, *attachments)
  entry = DICTIONARY.find(modifier).not_nil!.as(LModifier)
  modifier = Modifier.new entry
  attachments.each do |a|
    modifier.add_attachment(a)
  end
  modifier
end

def s(predicate : Predicate, arguments : Array(Argument?))
  Sentence.new(predicate, arguments)
end

def verb(v : String)
  DICTIONARY.find(v).not_nil!.as(Verb)
end

def noun(n : String)
  DICTIONARY.find(n).not_nil!.as(Noun)
end
