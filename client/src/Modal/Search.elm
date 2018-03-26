module Modal.Search exposing (Msg, update, view)

import Data.Search exposing (Search(..), Query, ViewLists)
import Dict exposing (Dict)
import Html exposing (Html, div)
import Search.BillSheet as BillSheet
import Search.Consumer as Consumer
import Search.Specialist as Specialist


type Msg
    = BillSheetMsg BillSheet.Msg
    | ConsumerMsg Consumer.Msg
    | SpecialistMsg Specialist.Msg



update : Maybe Query -> Msg -> ( Bool, Maybe Query )
update query msg =
    case msg of
        BillSheetMsg subMsg ->
            subMsg |> BillSheet.update query

        ConsumerMsg subMsg ->
            subMsg |> Consumer.update query

        SpecialistMsg subMsg ->
            subMsg |> Specialist.update query



view : Search -> Maybe Query -> Maybe ViewLists -> Html Msg
view t query viewLists =
    let
        searchView =
            case t of
                BillSheet ->
                    case viewLists of
                        Nothing ->
                            div [] []

                        Just lists ->
                            lists
                                |> BillSheet.view query
                                >> Html.map BillSheetMsg

                Consumer ->
                    query
                        |> Consumer.view
                        >> Html.map ConsumerMsg

                User ->
                    query
                        |> Specialist.view
                        >> Html.map SpecialistMsg

                _ ->
                    div [] []
    in
    div [] [ searchView ]

