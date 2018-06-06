module Search.Specialist exposing (Msg, update, view)

import Data.Search exposing (Search(..), Query)
import Dict exposing (Dict)
import Html exposing (Html, form, h3, text)
import Html.Attributes exposing (autofocus, value)
import Html.Events exposing (onInput, onSubmit)
import Search.Util exposing (getText, setText)
import Views.Form as Form



type Msg
    = Cancel
    | SetFormValue ( String -> Query ) String
    | Submit



update : Maybe Query -> Msg -> ( Bool, Maybe Query )
update query msg =
    case msg of
        Cancel ->
            ( False, query )

        SetFormValue setFormValue s ->
            ( True, s |> setFormValue |> Just )

        Submit ->
            ( False, query )



view : Maybe Query -> Html Msg
view query =
    let
        q =
            query
                |> Maybe.withDefault Dict.empty
    in
    form [ onSubmit Submit ]
        [ h3 [] [ "Specialist Search" |> text ]
        , Form.text "Last Name"
            [ True |> autofocus, ( "lastname" |> setText q ) |> SetFormValue >> onInput
            , "lastname" |> getText q |> value
            ]
            []
        , Form.submit ( q |> Dict.isEmpty ) Cancel
        ]


