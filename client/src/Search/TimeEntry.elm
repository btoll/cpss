module Search.TimeEntry exposing (Msg, update, view)

import Data.Search exposing (Search(..), Query, ViewLists)
import Dict exposing (Dict)
import Html exposing (Html, button, div, form, h3, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onInput, onSubmit)
import Search.Util exposing (getSelection, setSelection)
import Views.Form as Form



type Msg
    = Cancel
    | Select Form.Selection String
    | Submit



update : Maybe Query -> Msg -> ( Bool, Maybe Query )
update query msg =
    case msg of
        Cancel ->
            ( False, query )

        Select selectType selection ->
            let
                q =
                    query
                        |> Maybe.withDefault Dict.empty
            in
                ( True,
                    case selectType of
                        Form.ConsumerID ->
                            selection |> setSelection q "billsheet.consumer" |> Just

                        Form.CountyID ->
                            selection |> setSelection q "billsheet.county" |> Just

                        Form.ServiceCodeID ->
                            selection |> setSelection q "billsheet.serviceCode" |> Just

                        _ ->
                            Nothing
                )

        Submit ->
            ( False, query )



view : Maybe Query -> ViewLists -> Html Msg
view query viewLists =
    let
        q =
            query
                |> Maybe.withDefault Dict.empty

        consumers = Maybe.withDefault [] viewLists.consumers
        counties = Maybe.withDefault [] viewLists.counties
        serviceCodes = Maybe.withDefault [] viewLists.serviceCodes
    in
    form [ onSubmit Submit ]
        [ h3 [] [ "Bill Sheet Search" |> text ]
        , Form.select "Consumer"
            [ "consumerSelection" |> id
            , Select Form.ConsumerID |> onInput
            ] (
                consumers
                    |> List.map ( \m -> ( m.id |> toString, m.lastname ++ ", " ++ m.firstname ) )
                    |> (::) ( "-1", "-- Select a consumer --" )
                    |> List.map ( "billsheet.consumer" |> getSelection q |> Form.option )
            )
        , Form.select "Service Code"
            [ "serviceCodeSelection" |> id
            , Select Form.ServiceCodeID |> onInput
            ] (
                serviceCodes
                    |> List.map ( \m -> ( m.id |> toString, m.name ) )
                    |> (::) ( "-1", "-- Select a status --" )
                    |> List.map ( "billsheet.serviceCode" |> getSelection q |> Form.option )
            )
        , Form.select "County"
            [ "countySelection" |> id
            , Select Form.CountyID |> onInput
            ] (
                counties
                    |> List.map ( \m -> ( m.id |> toString, m.name ) )
                    |> (::) ( "-1", "-- Select a county --" )
                    |> List.map ( "billsheet.county" |> getSelection q |> Form.option )
            )
        , Form.submit ( q |> Dict.isEmpty ) Cancel
        ]


