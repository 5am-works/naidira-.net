module Naidira.WordGenerator.Generator

open System
open System.Text

let private tally (list: (string * int) list) =
   list
   |> List.fold
         (fun (acc, total) (next, nextValue) ->
            (((next, nextValue + total) :: acc), total + nextValue))
         ([], 0)
   |> fst
   |> List.rev

let private consonants =
   [ "p", 20
     "b", 10
     "m", 15
     "f", 5
     "v", 10
     "t", 25
     "d", 20
     "n", 20
     "s", 15
     "r", 10
     "l", 15
     "k", 15
     "g", 5 ]
   |> tally

let private consonantCap = List.last consonants |> snd

let private vowels =
   [ "a", 30
     "e", 25
     "i", 30
     "o", 15
     "u", 7
     "ai", 7
     "ei", 5
     "ou", 5
     "ui", 3 ]
   |> tally

let private vowelCap = List.last vowels |> snd

let private weightedChoice (random: Random) cap list =
   let roll = random.Next(cap)
   List.find (fun (_, value) -> roll < value) list |> fst

let private generateOrRepeat
   (random: Random)
   list
   cap
   (last: string option)
   repeatLimit
   =

   match last with
   | Some c when c.Length = 1 ->
      let repeat = random.Next(10)
      if repeat < repeatLimit then c else weightedChoice random cap list
   | _ -> weightedChoice random cap list

let private generateSyllable
   (random: Random)
   lastConsonant
   lastVowel
   : string * string =
   let consonant =
      generateOrRepeat random consonants consonantCap lastConsonant 3

   let vowel = generateOrRepeat random vowels vowelCap lastVowel 3
   (consonant, vowel)

let generateWord (random: Random) : string =
   let c1, v1 = generateSyllable random None None
   let c2, v2 = generateSyllable random (Some c1) (Some v1)
   let builder = StringBuilder()
   builder.Append(c1).Append(v1).Append(c2).Append(v2) |> ignore
   let mutable continueLimit = 0.4
   let mutable continueRoll = random.NextDouble()
   let mutable lastC = Some c2
   let mutable lastV = Some v2

   while continueRoll < continueLimit do
      let c, v = generateSyllable random lastC lastV
      lastC <- Some c
      lastV <- Some v
      builder.Append(c).Append(v) |> ignore
      continueLimit <- continueLimit * 0.4
      continueRoll <- random.NextDouble()

   builder.ToString()

let private generateList (count: int) (random: Random) : seq<string> =
   seq { 0..count } |> Seq.map (fun _ -> generateWord random)

let generateWords (count: int) : seq<string> =
   let random = Random()
   generateList count random

let generateWordsWithSeed (count: int) (seed: int) : seq<string> =
   let random = Random(seed)
   generateList count random
