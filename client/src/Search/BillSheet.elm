module Search.BillSheet exposing (Msg, update, view)

import Data.Search exposing (Search(..), Query, ViewLists)
import Dict exposing (Dict)
import Html exposing (Html, button, div, form, h3, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onInput, onSubmit)
import Views.Form as Form



type Msg
    = Cancel
    | Select Form.Selection String
    | Submit



update : Maybe Query -> Msg -> ( Bool, Maybe Query )
update query msg =
    case msg of
        Cancel ->
            ( False, Nothing )

        Select selectType selection ->
            let
                q =
                    query
                        |> Maybe.withDefault Dict.empty

                updateDict : String -> Query
                updateDict k =
                    if (==) selection "-1" then
                        q |> Dict.remove k
                    else
                        q |> Dict.insert k selection
            in
                ( True,
                    case selectType of
                        Form.ConsumerID ->
                            "consumer" |> updateDict |> Just

                        Form.CountyID ->
                            "county" |> updateDict |> Just

                        Form.SpecialistID ->
                            "specialist" |> updateDict |> Just

                        Form.StatusID ->
                            "status" |> updateDict |> Just

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
    in
    form [ onSubmit Submit ]
        [ h3 [] [ "Bill Sheet Search" |> text ]
        , Form.select "Consumer"
            [ "consumerSelection" |> id
            , Select Form.ConsumerID |> onInput
            ] (
                viewLists.consumers
                    |> List.map ( \m -> ( m.id |> toString, m.lastname ++ ", " ++ m.firstname ) )
                    |> (::) ( "-1", "-- Select a consumer --" )
                    |> List.map ( "-1" |> Form.option )
            )
        , Form.select "Status"
            [ "statusSelection" |> id
            , Select Form.StatusID |> onInput
            ] (
                viewLists.status
                    |> List.map ( \m -> ( m.id |> toString, m.name ) )
                    |> (::) ( "-1", "-- Select a status --" )
                    |> List.map ( "-1" |> Form.option )
            )
        , Form.select "Specialist"
            [ "specialistSelection" |> id
            , Select Form.SpecialistID |> onInput
            ] (
                viewLists.specialists
                    |> List.map ( \m -> ( m.id |> toString, m.lastname ++ ", " ++ m.firstname ) )
                    |> (::) ( "-1", "-- Select a specialist --" )
                    |> List.map ( "-1" |> Form.option )
            )
        , Form.select "County"
            [ "countySelection" |> id
            , Select Form.CountyID |> onInput
            ] (
                viewLists.counties
                    |> List.map ( \m -> ( m.id |> toString, m.name ) )
                    |> (::) ( "-1", "-- Select a consumer --" )
                    |> List.map ( "-1" |> Form.option )
            )
        , Form.submit ( q |> Dict.isEmpty ) Cancel
        ]


