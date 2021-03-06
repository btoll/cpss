module Views.Errors exposing (view)

import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class)



--view : List ( a, String ) -> Html msg
view : List String -> Html msg
view errors =
    if ( errors |> List.length ) == 0
    then
        div [] []
    else
        errors
            |> List.map
                ( \t ->
                    p [] [ t |> text ]
                )
            |> div [ class "error" ]


