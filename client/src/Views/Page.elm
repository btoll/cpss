module Views.Page exposing (ActivePage(..), frame)

import Html exposing (Html, a, div, footer, li, main_, nav, text, ul)
import Html.Attributes exposing (class, classList, id)
import Route exposing (Route)


type ActivePage
    = Other
    | Home
    | BillSheet
    | Consumer
    | Login
    | Logout
    | Specialist


type alias SiteLink msg =
    { page : ActivePage
    , route : Route
    , content : List ( Html msg )
    }


siteLinks : ActivePage -> List ( SiteLink a )
siteLinks page =
    if ( (==) ( toString page ) "Login" ) then
        [ SiteLink Login Route.Login [ text "Login" ] ]
    else
        [ SiteLink Home Route.Home [ text "Home" ]
        , SiteLink BillSheet Route.BillSheet [ text "Bill Sheet" ]
        , SiteLink Consumer Route.Consumer [ text "Consumer" ]
        , SiteLink Specialist Route.Specialist [ text "Specialist" ]
        , SiteLink Logout Route.Logout [ text "Logout" ]
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
                ( siteLinks page
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


