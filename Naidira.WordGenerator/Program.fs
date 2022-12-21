module Naidira.WordGenerator.Main

open System
open Naidira.WordGenerator.Generator

let generateSilika () =
   let mutable count = 0
   let random = Random(7)
   let mutable result = ""
   
   while result <> "silika" do
      result <- generateWord random
      count <- count + 1
   count

[<EntryPoint>]
let main args =
   printfn $"{generateSilika ()} attempts"
   0