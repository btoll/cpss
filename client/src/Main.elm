module Main exposing (..)

import Data.Specialist exposing (Specialist)
import Html exposing (..)
import Http
import Navigation
import Page.NotFound as NotFound
import Page.Specialist as Specialist
import Route exposing (Route)
import Task
import Views.Page as Page exposing (ActivePage)


type Page
    = Blank
    | NotFound
--    | Home Home.Model
--    | Errored PageLoadError
--    | Home Home.Model
    | Specialist Specialist.Model
--    | Login Login.Model



-- MODEL


type alias Model =
--    { session : Session
    { session : {}
    , page : Page
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    setRoute ( Route.fromLocation location )
        { page = initialPage
--        , session = { user = decodeUserFromJson val }
        , session = {}
        }


initialPage : Page
initialPage =
    Blank



-- UPDATE


type Msg
    = SetRoute ( Maybe Route )
    | SpecialistLoaded ( Result Http.Error Specialist.Model )
    | SpecialistMsg Specialist.Msg


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    case maybeRoute of
        Just Route.Home ->
            { model | page = Blank } ! []

        Just Route.Specialist ->
            ( model, Specialist.init |> Task.attempt SpecialistLoaded )

        _ ->
            model ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        toPage toModel subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
                -- Mapping the newCmd to SpecialistMsg causes the Elm runtime to call `update` again with the subsequent newCmd!
                { model | page = toModel newModel } ! [ Cmd.map SpecialistMsg newCmd ]
    in
        case ( msg, model.page ) of
            ( SetRoute route, _ ) ->
                setRoute route model

            ( SpecialistLoaded ( Ok subModel ), _ ) ->
                { model | page = Specialist subModel } ! []

            ( SpecialistLoaded ( Err err ), _ ) ->
                model ! []

            ( SpecialistMsg subMsg, Specialist subModel ) ->
                toPage Specialist Specialist.update subMsg subModel

            _ ->
                model ! []



-- VIEW


view : Model -> Html Msg
view model =
    let
        frame =
--            Page.frame isLoading session.user
            Page.frame
    in
    case model.page of
        Blank ->
            -- This is for the very initial page load, while we are loading
            -- data via HTTP. We could also render a spinner here.
            Html.text ""
                |> frame Page.Home

        NotFound ->
--            NotFound.view session
            NotFound.view
                |> frame Page.Other

--        Errored subModel ->
--            Errored.view session subModel
--                |> frame Page.Other

        Specialist subModel ->
--            Specialist.view session subModel
            Specialist.view subModel
                |> frame Page.Specialist
                |> Html.map SpecialistMsg

--        Home subModel ->
--            Home.view session subModel
--                |> frame Page.Home
--                |> Html.map HomeMsg



-- MAIN --


main : Program Never Model Msg
main =
    Navigation.program ( Route.fromLocation >> SetRoute )
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


