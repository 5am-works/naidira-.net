require "./parser/sentence"
require "./dictionary"

print "Enter a sentence: "
sentence = gets.not_nil!.chomp

begin
  result = parse sentence
  sentence = result[0]
  remaining_words = result[1]

  puts "Parsed #{sentence}"
  if !remaining_words.empty?
    puts "Remaining words: #{remaining_words}"
  end
rescue exception
  puts "Parse error: #{exception}"
end