module Modal.Delete exposing (Msg, update, view)

import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)


type Msg
    = Yes
    | No



update : Msg -> Bool
update msg =
    case msg of
        Yes ->
            True

        No ->
            False



view : Html Msg
view =
    div [ "delete" |> id ] [
        p [] [ text "Are you sure you wish to proceed?  This is irreversible!" ]
        , button [ Yes |> onClick ] [ text "Yes" ]
        , button [ No |> onClick ] [ text "No" ]
        ]


