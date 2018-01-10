module Views.Page exposing (ActivePage(..), frame)

import Html exposing (Html, a, div, footer, li, main_, nav, text, ul)
import Html.Attributes exposing (class, classList, id)
import Route exposing (Route)


type ActivePage
    = Other
    | Home
    | BillSheet
    | Specialist


type alias SiteLink msg =
    { page : ActivePage
    , route : Route
    , content : List ( Html msg )
    }


siteLinks : List ( SiteLink a )
siteLinks =
    [ SiteLink Home Route.Home [ text "Home" ]
    , SiteLink BillSheet Route.BillSheet [ text "Bill Sheet" ]
    , SiteLink Specialist Route.Specialist [ text "Specialist" ]
    ]


--frame : Bool -> Maybe User -> ActivePage -> Html msg -> Html msg
--frame isLoading user page content =
frame : ActivePage -> Html msg -> Html msg
frame page content =
    -- Add a page id to be able to target the current page (see navbar.css).
    main_ [ id ( ( toString page ) |> String.toLower ), class "page-frame" ]
        [ viewHeader page
        , content
        , viewFooter
        ]


--viewHeader : ActivePage -> Maybe User -> Bool -> Html msg
--viewHeader page user isLoading =
viewHeader : ActivePage -> Html msg
viewHeader page =
    nav [ class "navbar" ]
        [ div [ class "container" ]
            [ ul [ class "nav" ] <|
                ( siteLinks
                    |> List.map ( navbarLink <| page )
                )
            ]

        ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "container" ] []
        ]


navbarLink : ActivePage -> ( SiteLink a ) -> Html a
navbarLink currentPage { page, route, content } =
    li [ classList [ ( "nav-item", True ), ( "active", (==) currentPage page ) ] ]
        [ a [ class "nav-link", Route.href route ] content ]


