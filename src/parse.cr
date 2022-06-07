require "./parser/parser"
require "./dictionary"

include Naidira::Parser

print "Enter a sentence: "
sentence = gets.not_nil!.chomp

begin
  result = Naidira::Parser.parse sentence

  puts "Parsed: #{result}"
rescue exception
  puts "Parse error: #{exception}"
end
