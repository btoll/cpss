module Views.Page exposing (ActivePage(..), frame)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)


type ActivePage
    = Other
    | Home
    | Specialist


--frame : Bool -> Maybe User -> ActivePage -> Html msg -> Html msg
--frame isLoading user page content =
frame : ActivePage -> Html msg -> Html msg
frame page content =
    div [ class "page-frame" ]
        [ viewHeader page
        , content
        , viewFooter
        ]


--viewHeader : ActivePage -> Maybe User -> Bool -> Html msg
--viewHeader page user isLoading =
viewHeader : ActivePage -> Html msg
viewHeader page =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Route.href Route.Home ]
                [ text "benjamintoll.com" ]
            , ul [ class "nav navbar-nav pull-xs-right" ] <|
                [ navbarLink page Route.Home [ text "Home" ] ]
            ]

        ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "container" ]
            [ a [ class "logo-font", href "/" ] [ text "benjamintoll.com" ]
            , span [ class "attribution" ]
                [ text "An interactive learning project from "
                , a [ href "http://www.benjamintoll.com" ] [ text "benjamintoll.com" ]
                , text ". Code & design licensed under GPLv3."
                ]
            ]
        ]


navbarLink : ActivePage -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", isActive page route ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]


isActive : ActivePage -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

--        ( Login, Route.Login ) ->
--            True
--
--        ( Register, Route.Register ) ->
--            True
--
--        ( Settings, Route.Settings ) ->
--            True
--
--        ( Profile pageUsername, Route.Profile routeUsername ) ->
--            pageUsername == routeUsername
--
--        ( NewArticle, Route.NewArticle ) ->
--            True

        _ ->
            False


{-| This id comes from index.html.

The Feed uses it to scroll to the top of the page (by ID) when switching pages
in the pagination sense.

-}
bodyId : String
bodyId =
    "page-body"

