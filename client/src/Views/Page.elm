module Views.Page exposing (ActivePage(..), frame)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)


type ActivePage
    = Other
    | Home
    | Specialist


type alias SiteLink msg =
    { page : ActivePage
    , route : Route
    , content : List ( Html msg )
    }


siteLinks : List ( SiteLink a )
siteLinks =
    [ SiteLink Home Route.Home [ text "Home" ]
    , SiteLink Specialist Route.Specialist [ text "Specialist" ]
    ]


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
                ( siteLinks
                    |> List.map ( navbarLink <| page )
                )
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


navbarLink : ActivePage -> ( SiteLink a ) -> Html a
navbarLink currentPage siteLink =
    li [ classList [ ( "nav-item", True ), ( "active", (==) currentPage siteLink.page ) ] ]
        [ a [ class "nav-link", Route.href siteLink.route ] siteLink.content ]



{-| This id comes from index.html.

The Feed uses it to scroll to the top of the page (by ID) when switching pages
in the pagination sense.

-}
bodyId : String
bodyId =
    "page-body"


