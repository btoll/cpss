module Views.Page exposing (ActivePage(..), frame)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)


type ActivePage
    = Other
    | Home


--frame : Bool -> Maybe User -> ActivePage -> Html msg -> Html msg
--frame isLoading user page content =
frame : Bool -> ActivePage -> Html msg -> Html msg
frame isLoading page content =
    div [ class "page-frame" ]
        [ viewHeader page isLoading
        , content
        , viewFooter
        ]


--viewHeader : ActivePage -> Maybe User -> Bool -> Html msg
--viewHeader page user isLoading =
viewHeader : ActivePage -> Bool -> Html msg
viewHeader page isLoading =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Route.href Route.Home ]
                [ text "benjamintoll.com" ]
--            , ul [ class "nav navbar-nav pull-xs-right" ] <|
--                lazy2 Util.viewIf isLoading spinner
--                    :: navbarLink page Route.Home [ text "Home" ]
--                    :: viewSignIn page user
            , ul [ class "nav navbar-nav pull-xs-right" ] []
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


