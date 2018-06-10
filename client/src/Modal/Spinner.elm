module Modal.Spinner exposing (view)

import Html exposing (Html, div)
import Html.Attributes exposing (id)



view : Html msg
view =
    div [ "spinner" |> id ] []


