module Route exposing (Route(..), fromLocation, href, modifyUrl)

--import Data.Article as Article
--import Data.User as User exposing (Username)
import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)


-- ROUTING --


type Route
    = Home
    | BillSheet
    | Consumer
    | County
    | DIA
    | FundingSource
    | Login
    | Logout
    | ServiceCode
    | Specialist
    | Status
--    | TimeEntry


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (s "")
        , Url.map BillSheet (s "billsheet")
        , Url.map Consumer (s "consumer")
        , Url.map County (s "counties")
        , Url.map DIA (s "dia")
        , Url.map FundingSource (s "fundingSource")
        , Url.map Login (s "login")
        , Url.map Logout (s "logout")
        , Url.map ServiceCode (s "servicecode")
        , Url.map Specialist (s "specialist")
        , Url.map Status (s "status")
--        , Url.map TimeEntry (s "timeEntry")
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                BillSheet ->
                    [ "billsheet" ]

                Consumer ->
                    [ "consumer" ]

                County ->
                    [ "counties" ]

                DIA ->
                    [ "dia" ]

                FundingSource ->
                    [ "fundingSource" ]

                Login ->
                    [ "login" ]

                Logout ->
                    [ "logout" ]

                ServiceCode ->
                    [ "servicecode" ]

                Specialist ->
                    [ "specialist" ]

                Status ->
                    [ "status" ]

--                TimeEntry ->
--                    [ "timeEntry" ]
    in
        "#/" ++ String.join "/" pieces



-- PUBLIC HELPERS --


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        parseHash route location


