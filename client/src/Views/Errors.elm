module Views.Errors exposing (view)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class)



view : List String -> Html msg
view errors =
    errors
        |> List.map ( \s -> p [ class "error" ] [ text s ] )
        |> div []


