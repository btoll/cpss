module Search.TimeEntry exposing (Msg, update, view)

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
                    |> List.map ( "-1" |> Form.option )
            )
        , Form.select "Service Code"
            [ "serviceCodeSelection" |> id
            , Select Form.ServiceCodeID |> onInput
            ] (
                serviceCodes
                    |> List.map ( \m -> ( m.id |> toString, m.name ) )
                    |> (::) ( "-1", "-- Select a status --" )
                    |> List.map ( "-1" |> Form.option )
            )
        , Form.select "County"
            [ "countySelection" |> id
            , Select Form.CountyID |> onInput
            ] (
                counties
                    |> List.map ( \m -> ( m.id |> toString, m.name ) )
                    |> (::) ( "-1", "-- Select a consumer --" )
                    |> List.map ( "-1" |> Form.option )
            )
        , Form.submit ( q |> Dict.isEmpty ) Cancel
        ]


