module Naidira.Core.Lexicon

open System


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

type ParticleType =
   | NounParticle
   | VerbParticle
   | SentenceParticle

type WordKind =
   | Nounlike
   | Verblike
   | Any
   | Sentence

[<AbstractClass>]
type Word() =
   member val Spelling = "" with get, set
   member val SimpleMeaning = "" with get, set
   member val FullMeaning = "" with get, set
   member val FirstAppearance: string option = None with get, set
   abstract WordType: WordType

   member this.Meaning =
      if this.FullMeaning.Length = 0 then
         this.SimpleMeaning
      else
         this.FullMeaning

   interface IComparable with
      member this.CompareTo(other) =
         match other with
         | :? Word as word -> this.Spelling.CompareTo(word.Spelling)
         | _ -> failwithf $"Cannot compare with %s{other.ToString()}"

   override this.ToString() = this.Spelling

   override this.Equals(other) =
      match other with
      | :? Word as word -> this.Spelling = word.Spelling
      | _ -> false

   override this.GetHashCode() = this.Spelling.GetHashCode()

type Noun() =
   inherit Word()
   member val SentenceInitial = false with get, set
   override this.WordType = WordType.Noun

type Verb() =
   inherit Word()
   member val Valency = 0 with get, set
   member val FormattedMeaning = "" with get, set

   override this.WordType =
      match this.Valency with
      | 0 -> Verb0
      | 1 -> Verb1
      | _ -> Verb2

[<AbstractClass>]
type Modifier() =
   inherit Word()
   member val ModifiableTypes: WordKind[] = Array.empty with get, set
   member val AttachmentTypes: WordKind[] = Array.empty with get, set
   member val AttachmentNotes: string option[] = Array.empty with get, set

type PrefixModifier() =
   inherit Modifier()
   override this.WordType = WordType.PrefixModifier

type PostfixModifier() =
   inherit Modifier()
   override this.WordType = WordType.PostfixModifier

[<AbstractClass>]
type Particle() =
   inherit Word()
   member val ParticleType: ParticleType = NounParticle with get, set

type PrefixParticle() =
   inherit Particle()
   override this.WordType = WordType.PrefixParticle

type PostfixParticle() =
   inherit Particle()
   override this.WordType = WordType.PostfixParticle

type Lexicon() =
   member val Nouns: Noun[] = Array.empty with get, set
   member val Adjectives: Noun[] = Array.empty with get, set
   member val Verbs: Verb[] = Array.empty with get, set
   member val PrefixModifiers: PrefixModifier[] = Array.empty with get, set
   member val PostfixModifiers: PostfixModifier[] = Array.empty with get, set
   member val PrefixParticles: PrefixParticle[] = Array.empty with get, set
   member val PostfixParticles: PostfixParticle[] = Array.empty with get, set

   member this.Index =
      Seq.cast this.Nouns
      |> Seq.append (Seq.cast this.Verbs)
      |> Seq.append (Seq.cast this.Adjectives)
      |> Seq.append (Seq.cast this.PostfixModifiers)
      |> Seq.append (Seq.cast this.PrefixModifiers)
      |> Seq.append (Seq.cast this.PostfixParticles)
      |> Seq.append (Seq.cast this.PrefixParticles)
      |> Seq.map (fun (word: Word) -> word.Spelling, word)
      |> Map.ofSeq

   member this.WordCount =
      this.Nouns.Length
      + this.Adjectives.Length
      + this.Verbs.Length
      + this.PrefixModifiers.Length
      + this.PostfixModifiers.Length
      + this.PrefixParticles.Length
      + this.PostfixParticles.Length

   member this.Lookup(word: string) : Word option = Map.tryFind word this.Index

   member this.Get(word: string) = Map.find word this.Index
