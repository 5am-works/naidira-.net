require "./parser/parser"
require "./dictionary"

print "Enter a sentence: "
sentence = gets.not_nil!.chomp

begin
  result = parse sentence

  puts "Parsed: #{result}"
rescue exception
  puts "Parse error: #{exception}"
end