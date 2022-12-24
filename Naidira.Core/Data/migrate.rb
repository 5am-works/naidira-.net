require 'yaml'

original = YAML.load_file('lexicon.yaml')
words = original['words']

new_dictionary = {
   'nouns' => [],
   'adjectives' => [],
   'verbs' => [],
   'prefix_modifiers' => [],
   'postfix_modifiers' => [],
   'prefix_particles' => [],
   'postfix_particles' => [],
}

words.values.each do |word|
   new_word = {
      'spelling' => word['spelling'],
      'simple_meaning' => word['simple_meaning'],
      'first_appearance' => word['first_appearance']
   }

   case word['type']
   when 'noun'
      new_dictionary['nouns'] << new_word
   when 'adjective'
      new_dictionary['adjectives'] << new_word
   when 'verb0', 'verb1', 'verb2'
      valency = word['type'][-1].to_i
      new_word['valency'] = valency
      new_word['formatted_meaning'] = word['formatted_meaning']

      new_dictionary['verbs'] << new_word
   when 'prefix_modifier', 'postfix_modifier'
      new_word['modifiable_types'] = word['modifiable_types']
      new_word['attachment_types'] = word['attachment_types']
      new_word['attachment_notes'] = word['attachment_notes']

      if word['type'] == 'prefix_modifier'
         new_dictionary['prefix_modifiers'] << new_word
      else
         new_dictionary['postfix_modifiers'] << new_word
      end
   when 'prefix_particle'
      new_dictionary['prefix_particles'] << new_word
   when 'postfix_particle'
      new_dictionary['postfix_particles'] << new_word
   else
      raise "Unrecognized word type: #{word['type']}"
   end
end

File.write('dictionary.yaml', new_dictionary.to_yaml)