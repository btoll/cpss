module Views.Page exposing (ActivePage(..), ViewAction(..), frame)

import Data.User exposing (User)
import Html exposing (Html, a, div, footer, li, main_, nav, p, text, ul)
import Html.Attributes exposing (class, classList, id)
import Route exposing (Route)


type ActivePage
    = Other
    | Home
    | BillSheet
    | Consumer
    | County
    | Login
    | Logout
    | ServiceCode
    | Specialist
    | Status
    | TimeEntry



type ViewAction
    = None
    | Adding
    | Editing



type alias SiteLink msg =
    { page : ActivePage
    , route : Route
    , content : List ( Html msg )
    }


siteLinks : Maybe User -> ActivePage -> List ( SiteLink a )
siteLinks user page =
    case user of
        Nothing ->
            [ SiteLink Login Route.Login [ text "Login" ] ]

        Just user ->
            case user.authLevel of
                1 ->
                    [ SiteLink Home Route.Home [ text "Home" ]
                    , SiteLink BillSheet Route.BillSheet [ text "Bill Sheet" ]
                    , SiteLink Consumer Route.Consumer [ text "Consumer" ]
                    , SiteLink Specialist Route.Specialist [ text "Specialist" ]
                    , SiteLink Status Route.Status [ text "Status" ]
                    , SiteLink County Route.County [ text "Cities / Counties" ]
                    , SiteLink ServiceCode Route.ServiceCode [ text "Service Code" ]
                    , SiteLink Logout Route.Logout [ text "Logout" ]
                    ]
                _ ->
                    [ SiteLink Home Route.Home [ text "Home" ]
                    , SiteLink TimeEntry Route.TimeEntry [ text "Time Entry" ]
                    , SiteLink Logout Route.Logout [ text "Logout" ]
                    ]


--frame : Bool -> Maybe User -> ActivePage -> Html msg -> Html msg
--frame isLoading user page content =
frame : Maybe User -> ActivePage -> Html msg -> Html msg
frame user page content =
    -- Add a page id to be able to target the current page (see navbar.css).
    main_ [ id ( ( toString page ) |> String.toLower ), class "page-frame" ]
        [ viewHeader user page
        , content
        , viewFooter
        ]


greeting : Maybe User -> Html msg
greeting user =
    case user of
        Nothing ->
            div [] []

        Just user ->
            div [] [
                p [] [ text ( (++) ( (++) "Welcome " user.username ) "!" ) ]
            ]


--viewHeader : ActivePage -> Maybe User -> Bool -> Html msg
--viewHeader page user isLoading =
viewHeader : Maybe User -> ActivePage -> Html msg
viewHeader user page =
    nav [ class "navbar" ]
        [ div [ class "container" ]
            [ ul [ class "nav" ] <|
                ( siteLinks user page
                    |> List.map ( navbarLink <| page )
                )
            , greeting <| user
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


