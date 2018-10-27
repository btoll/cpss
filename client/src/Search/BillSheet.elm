module Search.BillSheet exposing (Msg, defaultQuery, update, view)

import Data.Search exposing (Query, ViewLists)
import Data.User exposing (User)
import Dict exposing (Dict)
import Html exposing (Html, button, div, form, h3, text)
import Html.Attributes exposing (autofocus, id, placeholder, value)
import Html.Events exposing (onInput, onSubmit)
import Util.Search exposing (getSelection, setSelection, getText, setText)
import Views.Form as Form



type Msg
    = Cancel
    | Select Form.Selection String
    | SetFormValue ( String -> Query ) String
    | Submit



defaultQuery : User -> ( String, Maybe ( Dict String String ) )
defaultQuery user =
    if (==) 1 user.authLevel
    then
        (
            ""
            ,  Nothing
        )
    else
        (
            (++) "specialist=" ( user.id |> toString )
            , [ ( "specialist", ( user.id |> toString ) ) ] |> Dict.fromList |> Just
        )



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

                        Form.SpecialistID ->
                            selection |> setSelection q "billsheet.specialist" |> Just

                        Form.StatusID ->
                             selection |> setSelection q "billsheet.status" |> Just

                        _ ->
                            Nothing
                )

        SetFormValue setFormValue s ->
            ( True, s |> setFormValue |> Just )

        Submit ->
            ( False, query )



view : User -> Maybe Query -> ViewLists -> Html Msg
view user query viewLists =
    let
        q =
            query
                |> Maybe.withDefault Dict.empty

        consumers = Maybe.withDefault [] viewLists.consumers
        counties = Maybe.withDefault [] viewLists.counties
        serviceCodes = Maybe.withDefault [] viewLists.serviceCodes
        specialists = Maybe.withDefault [] viewLists.specialists
        status = Maybe.withDefault [] viewLists.status
    in
    case user.authLevel of
        1 ->
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
                            |> (::) ( "-1", "-- Select a service code --" )
                            |> List.map ( "billsheet.serviceCode" |> getSelection q |> Form.option )
                    )
                , Form.select "Status"
                    [ "statusSelection" |> id
                    , Select Form.StatusID |> onInput
                    ] (
                        status
                            |> List.map ( \m -> ( m.id |> toString, m.name ) )
                            |> (::) ( "-1", "-- Select a status --" )
                            |> List.map ( "billsheet.status" |> getSelection q |> Form.option )
                    )
                , Form.select "Specialist"
                    [ "specialistSelection" |> id
                    , Select Form.SpecialistID |> onInput
                    ] (
                        specialists
                            |> List.map ( \m -> ( m.id |> toString, m.lastname ++ ", " ++ m.firstname ) )
                            |> (::) ( "-1", "-- Select a specialist --" )
                            |> List.map ( "billsheet.specialist" |> getSelection q |> Form.option )
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
                , Form.text "Service Date From"
                    [ True |> autofocus
                    , ( "serviceDateFrom" |> setText q ) |> SetFormValue >> onInput
                    , "serviceDateFrom" |> getText q |> value
                    , "MM/DD/YY" |> placeholder
                    ]
                    []
                , Form.text "Service Date To"
                    [ True |> autofocus
                    , ( "serviceDateTo" |> setText q ) |> SetFormValue >> onInput
                    , "serviceDateTo" |> getText q |> value
                    , "MM/DD/YY" |> placeholder
                    ]
                    []
                , Form.submit ( q |> Dict.isEmpty ) Cancel
                ]

        2 ->
            form [ onSubmit Submit ]
                [ h3 [] [ "Time Entry Search" |> text ]
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
                , Form.text "Service Date From"
                    [ True |> autofocus
                    , ( "serviceDateFrom" |> setText q ) |> SetFormValue >> onInput
                    , "serviceDateFrom" |> getText q |> value
                    , "MM/DD/YY" |> placeholder
                    ]
                    []
                , Form.text "Service Date To"
                    [ True |> autofocus
                    , ( "serviceDateTo" |> setText q ) |> SetFormValue >> onInput
                    , "serviceDateTo" |> getText q |> value
                    , "MM/DD/YY" |> placeholder
                    ]
                    []
                , Form.submit ( q |> Dict.isEmpty ) Cancel
                ]

        _ ->
            div [] []


