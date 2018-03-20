module Views.Modal exposing (Modal(..), Msg, update, view)

import Data.App exposing (App(..), Query, ViewLists)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, text)
import Html.Attributes exposing (style)
import Modal.Delete as Delete
import Modal.Search as Search



maskStyle : Attribute msg
maskStyle =
  style
    [ ("background-color", "rgba(0,0,0,0.3)")
    , ("position", "fixed")
    , ("top", "0")
    , ("left", "0")
    , ("width", "100%")
    , ("height", "100%")
    ]


modalStyle : Attribute msg
modalStyle =
  style
    [ ("background-color", "rgba(255,255,255,1.0)")
    , ("position", "absolute")
    , ("top", "50%")
    , ("left", "50%")
    , ("height", "auto")
    , ("max-height", "80%")
    , ("width", "700px")
    , ("max-width", "95%")
    , ("padding", "10px")
    , ("border-radius", "3px")
    , ("box-shadow", "1px 1px 5px rgba(0,0,0,0.5)")
    , ("transform", "translate(-50%, -50%)")
    ]



type Modal
    = Delete
    | Search App ( Maybe Query ) ( Maybe ViewLists )


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
            div [ maskStyle ] [
                div [ modalStyle ] [ view ]
                ]

        ( _, _ ) ->
            div [] []


