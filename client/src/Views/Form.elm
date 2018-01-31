module Views.Form exposing (
    float
    , text
    , toFloat
    )

import Html exposing (Html, Attribute, div, input, label, text)
import Html.Attributes exposing (for, id, type_, value)
import Html.Events exposing (onInput)



control :
    String ->
    ( List ( Attribute msg ) -> List ( Html msg ) -> Html msg ) ->
    List ( Attribute msg ) ->
    List ( Html msg ) ->
    Html msg
control name element attrs children =
    div [] [
        label [ prepareId name |> for ] [ Html.text name ]
        , element attrs children
    ]


-- Remove any spaces in name (`id` attr doesn't allow for spaces).
prepareId : String -> String
prepareId name =
    name
        |> String.words
        |> String.concat


toFloat : String -> Float
toFloat v =
    String.toFloat v
        |> Result.withDefault 0.00


float : String -> List ( Attribute msg ) -> List ( Html msg ) -> Html msg
float name attrs =
    control name input ( [ type_ "number" ] ++ attrs )


text : String -> List ( Attribute msg ) -> List ( Html msg ) -> Html msg
text name attrs =
    control name input ( [ type_ "text" ] ++ attrs )


