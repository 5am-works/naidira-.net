using Microsoft.FSharp.Core;

namespace Naidira.Functions; 

public static class Utils {
   public static T? ToNullable<T>(this FSharpOption<T> option) {
      return FSharpOption<T>.get_IsSome(option) ? option.Value : default;
   }
}