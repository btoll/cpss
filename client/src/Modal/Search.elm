module Modal.Search exposing (Msg, update, view)

import Data.App exposing (App(..), Query, ViewLists)
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

        _ ->
            ( True, Nothing )



view : App -> Maybe Query -> Maybe ViewLists -> Html Msg
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
                                |> Html.map BillSheetMsg

                Consumer ->
                    Consumer.view
                        |> Html.map ConsumerMsg

                User ->
                    Specialist.view
                        |> Html.map SpecialistMsg

                _ ->
                    div [] []
    in
    div [] [ searchView ]


