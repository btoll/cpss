module Modal.Search exposing (Msg, update, view)

import Data.Search exposing (SearchType(..), Query, ViewLists)
import Data.User exposing (User)
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



view : SearchType -> User -> Maybe Query -> Maybe ViewLists -> Html Msg
view t user query viewLists =
    let
        searchView =
            case t of
                BillSheet ->
                    case viewLists of
                        Nothing ->
                            div [] []

                        Just lists ->
                            lists
                                |> BillSheet.view user query
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


