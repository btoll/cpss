module Views.Modal exposing (Modal(..), Msg, update, view)

import Data.Search exposing (SearchType(..), Query, ViewLists)
import Data.User exposing (User, new)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, text)
import Html.Attributes exposing (id, style)
import Modal.Delete as Delete
import Modal.Search as Search
import Modal.Spinner as Spinner



type Modal
    = Delete
    | Search SearchType ( Maybe User ) ( Maybe Query ) ( Maybe ViewLists )
    | Spinner


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



view : Maybe User -> Maybe Query -> ( Bool, Maybe Modal ) -> Html Msg
view user query modal =
    case modal of
        ( True, Just modal ) ->
            let
                view : Html Msg
                view =
                    case modal of
                        Delete ->
                            Delete.view
                                |> Html.map DeleteMsg

                        Search t user q maybeViewLists ->
                            let
                                u =
                                    user
                                        |> Maybe.withDefault new
                            in
                            case ( t, maybeViewLists ) of
                                _ ->
                                    maybeViewLists
                                        |> Search.view t u query      -- Note we want the passed `query` func arg here, NOT `q`!
                                        |> Html.map SearchMsg

                        Spinner ->
                            Spinner.view
            in
            div [ "modal-mask" |> id ] [
                div [ "modal-content" |> id ] [ view ]
                ]

        ( _, _ ) ->
            div [] []


