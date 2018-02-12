module Views.Errors exposing (view)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class)



view : List ( a, String ) -> Html msg
view errors =
    errors
        |> List.map
            ( \t ->
                let
                    tipe = t |> Tuple.first |> toString
                    description = t |> Tuple.second
                in
                p [ class "error" ] [ (++) tipe description |> text ]
            )
        |> div []


