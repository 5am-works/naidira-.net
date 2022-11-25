module Naidira.Lexicon.Lexicon

type WordType =
   | Unknown
   | Noun
   | Adjective
   | Verb0
   | Verb1
   | Verb2
   | PrefixModifier
   | PostfixModifier
   | PrefixParticle
   | PostfixParticle
   
type WordKind =
   | Nounlike
   | Verblike
   | Any
   | Sentence

[<AbstractClass>]
type Word() =
   member val Spelling = "" with get, set
   member val SimpleMeaning = "" with get, set
   member val FirstAppearance: string option = None with get, set
   abstract WordType: WordType with get
   
type Noun() =
   inherit Word()
   override this.WordType = WordType.Noun
   
type Adjective() =
   inherit Word()
   override this.WordType = WordType.Adjective
   
type Verb() =
   inherit Word()
   member val Valency = 0 with get, set
   member val FormattedMeaning = "" with get, set
   override this.WordType =
      match this.Valency with
      | 0 -> Verb0
      | 1 -> Verb1
      | _ -> Verb2
      
type PrefixModifier() =
   inherit Word()
   member val ModifiableTypes: WordKind[] = Array.empty with get, set
   member val AttachmentTypes: WordKind[] = Array.empty with get, set
   member val AttachmentNotes: string option[] = Array.empty with get, set
   override this.WordType = WordType.PrefixModifier
   
type PostfixModifier() =
   inherit Word()
   member val ModifiableTypes: WordKind[] = Array.empty with get, set
   member val AttachmentTypes: WordKind[] = Array.empty with get, set
   member val AttachmentNotes: string option[] = Array.empty with get, set
   override this.WordType = WordType.PostfixModifier

type PrefixParticle() =
   inherit Word()
   override this.WordType = WordType.PrefixParticle

type PostfixParticle() =
   inherit Word()
   override this.WordType = WordType.PostfixParticle

type Lexicon() =
   member val Nouns: Noun[] = Array.empty with get, set
   member val Adjectives: Adjective[] = Array.empty with get, set
   member val Verbs: Verb[] = Array.empty with get, set
   member val PrefixModifiers: PrefixModifier[] = Array.empty with get, set
   member val PostfixModifiers: PostfixModifier[] = Array.empty with get, set
   member val PrefixParticles: PrefixModifier[] = Array.empty with get, set
   member val PostfixParticles: PrefixModifier[] = Array.empty with get, set
   
   member this.WordCount with get() =
      this.Nouns.Length + this.Adjectives.Length + this.Verbs.Length + this.PrefixModifiers.Length +
         this.PostfixModifiers.Length + this.PrefixParticles.Length + this.PostfixParticles.Length