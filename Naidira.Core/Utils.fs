module Naidira.Core.Utils

let foldResult f state (items: seq<'a>) =
   let enumerator = items.GetEnumerator()
   let rec fold s =
      if enumerator.MoveNext() then
         match f s enumerator.Current with
         | Ok(r) -> fold r
         | Error(e) -> Error e
      else
         Ok state
   fold state

let altResult result2Thunk result1 =
   match result1 with
   | Ok r -> Ok r
   | Error error -> result2Thunk error