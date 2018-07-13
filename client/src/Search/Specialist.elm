module Search.Specialist exposing (Msg, defaultQuery, update, view)

import Data.Search exposing (Query)
import Dict exposing (Dict)
import Html exposing (Html, form, h3, text)
import Html.Attributes exposing (autofocus, checked, value)
import Html.Events exposing (onCheck, onInput, onSubmit)
import Util.Search exposing (getBool, getText, setBool, setText)
import Views.Form as Form



type Msg
    = Cancel
    | SetCheckboxValue ( Bool -> Query ) Bool
    | SetFormValue ( String -> Query ) String
    | Submit



defaultQuery : Dict String String
defaultQuery =
    [ ( "active", "1" )] |> Dict.fromList



update : Maybe Query -> Msg -> ( Bool, Maybe Query )
update query msg =
    case msg of
        Cancel ->
            ( False, query )

        SetCheckboxValue setBoolValue b ->
            ( True, b |> setBoolValue |> Just )

        SetFormValue setFormValue s ->
            ( True, s |> setFormValue |> Just )

        Submit ->
            ( False, query )



view : Maybe Query -> Html Msg
view query =
    let
        q =
            query
                |> Maybe.withDefault defaultQuery
    in
    form [ onSubmit Submit ]
        [ h3 [] [ "Specialist Search" |> text ]
        , Form.checkbox "Active"
            [ ( "active" |> setBool q ) |> SetCheckboxValue |> onCheck
            , "active" |> getBool q |> checked
            ]
            []
        , Form.text "Last Name"
            [ True |> autofocus, ( "lastname" |> setText q ) |> SetFormValue >> onInput
            , "lastname" |> getText q |> value
            ]
            []
        , Form.submit ( q |> Dict.isEmpty ) Cancel
        ]


