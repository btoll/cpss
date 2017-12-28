module Main exposing (..)

import Html exposing (..)
import Navigation
import Page.NotFound as NotFound
import Page.Specialist as Specialist
import Route exposing (Route)
import Views.Page as Page exposing (ActivePage)


type Page
    = Blank
    | NotFound
--    | Errored PageLoadError
--    | Home Home.Model
    | Specialist Specialist.Model
--    | Login Login.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- MODEL


type alias Model =
--    { session : Session
    { session : {}
    , pageState : PageState
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    setRoute ( Route.fromLocation location )
        { pageState = Loaded initialPage
--        , session = { user = decodeUserFromJson val }
        , session = {}
        }


initialPage : Page
initialPage =
    Blank



-- UPDATE


type Msg
    = SetRoute ( Maybe Route )
    | SpecialistMsg Specialist.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    case maybeRoute of
        Just Route.Home ->
            model ! []

        Just Route.Specialist ->
            model ! []

        _ ->
            model ! []



-- VIEW


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
--            viewPage model.session False page
            viewPage False page

        TransitioningFrom page ->
--            viewPage model.session True page
            viewPage True page


--viewPage : Session -> Bool -> Page -> Html Msg
--viewPage session isLoading page =
viewPage : Bool -> Page -> Html Msg
viewPage isLoading page =
    let
        frame =
--            Page.frame isLoading session.user
            Page.frame isLoading
    in
    case page of
        Blank ->
            -- This is for the very initial page load, while we are loading
            -- data via HTTP. We could also render a spinner here.
            Html.text ""
                |> frame Page.Other

        NotFound ->
--            NotFound.view session
            NotFound.view
                |> frame Page.Other

--        Errored subModel ->
--            Errored.view session subModel
--                |> frame Page.Other

--        Specialist subModel ->
--            Specialist.view session subModel
--                |> frame Page.Other
--                |> Html.map SpecialistMsg

--        Home subModel ->
--            Home.view session subModel
--                |> frame Page.Home
--                |> Html.map HomeMsg

        _ ->
            div [] []




-- MAIN --


main : Program Never Model Msg
main =
    Navigation.program ( Route.fromLocation >> SetRoute )
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


