module Views.Modal exposing (Modal(..), Msg, update, view)

import Data.Search exposing (Search(..), Query, ViewLists)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, text)
import Html.Attributes exposing (id, style)
import Modal.Delete as Delete
import Modal.Search as Search



type Modal
    = Delete
    | Search Search ( Maybe Query ) ( Maybe ViewLists )


type Msg
    = DeleteMsg Delete.Msg
    | SearchMsg Search.Msg



update : Maybe Query -> Msg -> ( Bool, Maybe Query )
update query msg =
    case msg of
        DeleteMsg subMsg ->
            ( Delete.update subMsg, Nothing )

        SearchMsg subMsg ->
            Search.update query subMsg



view : Maybe Query -> ( Bool, Maybe Modal ) -> Html Msg
view query modal =
    case modal of
        ( True, Just modal ) ->
            let
                view : Html Msg
                view =
                    case modal of
                        Delete ->
                            Delete.view
                                |> Html.map DeleteMsg

                        Search t q maybeViewLists ->
                            case ( t, maybeViewLists ) of
                                _ ->
                                    maybeViewLists
                                        |> Search.view t query      -- Note we want the passed `query` func arg here, NOT `q`!
                                        |> Html.map SearchMsg
            in
            div [ "modal-mask" |> id ] [
                div [ "modal-content" |> id ] [ view ]
                ]

        ( _, _ ) ->
            div [] []


