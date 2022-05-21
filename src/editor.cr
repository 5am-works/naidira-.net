require "./dictionary"

dictionary = Dictionary.new

loop do
  puts "Enter an option:
1. Search for words
2. Add a word
0. Quit
"

  input = gets.try &.to_i
  case input
  when 1
    print "Enter a word: "
    input = gets.try &.chomp
    result = dictionary.find(input)
    if result.nil?
      puts "Word not found"
    else
      puts result.pp
    end
  when 2
    puts "TODO"
  when 0
    break
  else
    puts "Invalid selection"
  end
end