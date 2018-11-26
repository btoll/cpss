module Util.String exposing (toFloat , toInt)


toFloat : String -> Float
toFloat v =
    String.toFloat v
        |> Result.withDefault 0.00


toInt : String -> Int
toInt v =
    String.toInt v
        |> Result.withDefault 0


