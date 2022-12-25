module Naidira.Core.LexiconLoader

open System
open System.IO
open System.Reflection
open Naidira.Core.Lexicon
open YamlDotNet.Core
open YamlDotNet.Core.Events
open YamlDotNet.Serialization
open YamlDotNet.Serialization.NamingConventions

type WordKindConverter() =
   interface IYamlTypeConverter with
      member this.Accepts(targetType) = targetType = typeof<WordKind>
      
      member this.ReadYaml(parser, targetType) =
         let value = parser.Consume<Scalar>().Value
         match value with
         | "nounlike" -> Nounlike
         | "verblike" -> Verblike
         | "any" -> Any
         | "sentence" -> Sentence
         | _ -> failwithf $"Invalid word kind: {value}"
      
      member this.WriteYaml(emitter, value, targetType) = ()

type ParticleTypeConverter() =
   interface IYamlTypeConverter with
      member this.Accepts(targetType) = targetType = typeof<ParticleType>
      member this.ReadYaml(parser, _) =
         let value = parser.Consume<Scalar>().Value
         match value with
         | "noun" -> NounParticle
         | "verb" -> VerbParticle
         | "sentence" -> SentenceParticle
         | _ -> failwith $"Invalid particle type: {value}"
         
      member this.WriteYaml(emitter, value, targetType) = ()

let lexiconInstance =
   lazy
      let deserializer =
         DeserializerBuilder()
            .WithNamingConvention(UnderscoredNamingConvention.Instance)
            .WithTypeConverter(WordKindConverter())
            .WithTypeConverter(ParticleTypeConverter())
            .Build()

      let file =
         Assembly
            .GetExecutingAssembly()
            .GetManifestResourceStream("Naidira.Lexicon.dictionary.yaml")

      deserializer.Deserialize<Lexicon>(new StreamReader(file))