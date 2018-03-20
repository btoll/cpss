module Search.Specialist exposing (Msg, update, view)

import Data.App exposing (App(..), Query)
import Dict exposing (Dict)
import Html exposing (Html, form, h3, text)
import Html.Events exposing (onClick, onSubmit)
import Views.Form as Form


type Msg
    = Cancel
    | Submit



update : Maybe Query -> Msg -> ( Bool, Maybe Query )
update query msg =
    let
        q =
            query
                |> Maybe.withDefault Dict.empty
    in
    case msg of
        Cancel ->
            ( False, Nothing )

        Submit ->
            ( True, Nothing )



view : Html Msg
view =
    form [ onSubmit Submit ]
        [ h3 [] [ "Specialist Search" |> text ]
        , Form.text "Last Name"
            []
--                            [ value editable.bsu
--                            , onInput ( SetFormValue (\v -> { editable | bsu = v } ) )
--                            ]
            []
        , Form.submit False Cancel
        ]


