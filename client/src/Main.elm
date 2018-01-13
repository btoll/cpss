module Main exposing (..)

import Data.BillSheet exposing (BillSheet)
import Data.Consumer exposing (Consumer)
import Data.Session exposing (Session)
import Data.Specialist exposing (Specialist)
import Html exposing (..)
import Http
import Navigation
import Page.BillSheet as BillSheet
import Page.Consumer as Consumer
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Specialist as Specialist
import Ports exposing (fileContentRead, fileSelected)
import Route exposing (Route)
import Task
import Views.Page as Page exposing (ActivePage)


type alias Build =
    {
        url : String
    }


type alias Flags =
    {
        env : Maybe String
    }


type Page
    = Blank
    | NotFound
--    | Home Home.Model
--    | Errored PageLoadError
    | Errored
--    | Home Home.Model
    | BillSheet BillSheet.Model
    | Consumer Consumer.Model
    | Login Login.Model
    | Specialist Specialist.Model



-- MODEL


type alias Model =
    { session : Session
    , build : Build
    , page : Page
    , onLogin : Maybe Route     -- Capture the route with which to redirect the user after login.
    }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        url =
            if ( Maybe.withDefault "dev" flags.env ) == "production"
            then "https://www.benjamintoll.com/cpss"
            else "http://localhost:8080/cpss"
    in
        setRoute ( Route.fromLocation location )
            { session = { user = Nothing }
            , build = { url = url }
            , page = initialPage
            , onLogin = Nothing
            }


initialPage : Page
initialPage =
    Blank



-- UPDATE


type Msg
    = SetRoute ( Maybe Route )
    | BillSheetLoaded ( Result Http.Error BillSheet.Model )
    | BillSheetMsg BillSheet.Msg
    | ConsumerLoaded ( Result Http.Error Consumer.Model )
    | ConsumerMsg Consumer.Msg
    | LoginMsg Login.Msg
    | SpecialistLoaded ( Result Http.Error Specialist.Model )
    | SpecialistMsg Specialist.Msg


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    case maybeRoute of
        Just Route.Home ->
            case model.session.user of
                Nothing ->
                    { model |
                        page = Login Login.init
                        , onLogin = maybeRoute
                    } ! []

                Just user ->
                    { model | page = Blank } ! []

        Just Route.BillSheet ->
            case model.session.user of
                Nothing ->
                    let
                        loginModel = Login.init
                    in
                    { model |
                        page = Login loginModel
                        , onLogin = maybeRoute
                    } ! []

                Just user ->
                    ( model, BillSheet.init model.build.url |> Task.attempt BillSheetLoaded )

        Just Route.Consumer ->
            case model.session.user of
                Nothing ->
                    { model |
                        page = Login Login.init
                        , onLogin = maybeRoute
                    } ! []

                Just user ->
                    ( model, Consumer.init model.build.url |> Task.attempt ConsumerLoaded )

        Just Route.Logout ->
            let
                session = model.session
            in
            { model |
                page = Login Login.init
                , session = { session | user = Nothing }
            } ! []

        Just Route.Specialist ->
            case model.session.user of
                Nothing ->
                    { model |
                        page = Login Login.init
                        , onLogin = maybeRoute
                    } ! []

                Just user ->
                    ( model, Specialist.init model.build.url |> Task.attempt SpecialistLoaded )

        _ ->
            { model | page = Login Login.init } ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate model.build.url subMsg subModel
            in
                -- Mapping the newCmd to SpecialistMsg causes the Elm runtime to call `update` again with the subsequent newCmd!
                { model | page = toModel newModel } ! [ Cmd.map toMsg newCmd ]
    in
        case ( msg, model.page ) of
            ( SetRoute route, _ ) ->
                setRoute route model

            ( BillSheetLoaded ( Ok subModel ), _ ) ->
                { model | page = BillSheet subModel } ! []

            ( BillSheetLoaded ( Err err ), _ ) ->
                model ! []

            ( BillSheetMsg subMsg, BillSheet subModel ) ->
                toPage BillSheet BillSheetMsg BillSheet.update subMsg subModel

            ( ConsumerLoaded ( Ok subModel ), _ ) ->
                { model | page = Consumer subModel } ! []

            ( ConsumerLoaded ( Err err ), _ ) ->
                model ! []

            ( ConsumerMsg subMsg, Consumer subModel ) ->
                toPage Consumer ConsumerMsg Consumer.update subMsg subModel

            ( LoginMsg subMsg, Login subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Login.update model.build.url subMsg subModel

                    ( newModel, newCmd )  =
                        case msgFromPage of
                            Login.NoOp ->
                                ( { model | page = Login pageModel }, Cmd.none )

                            Login.SetUser user ->
                                let
                                    session =
                                        model.session
                                in
                                    { model |
                                        session = { user = Just user }
                                        , page = Blank
                                        , onLogin = Nothing
                                    } |> setRoute model.onLogin -- Redirect after having had logged in.
                in
                    ( newModel, newCmd )

            ( SpecialistLoaded ( Ok subModel ), _ ) ->
                { model | page = Specialist subModel } ! []

            ( SpecialistLoaded ( Err err ), _ ) ->
                model ! []

            ( SpecialistMsg subMsg, Specialist subModel ) ->
                toPage Specialist SpecialistMsg Specialist.update subMsg subModel

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

        BillSheet subModel ->
--            BillSheet.view session subModel
            BillSheet.view subModel
                |> frame Page.BillSheet
                |> Html.map BillSheetMsg

        Consumer subModel ->
--            Consumer.view session subModel
            Consumer.view subModel
                |> frame Page.Consumer
                |> Html.map ConsumerMsg

        Errored ->
            Html.text "Errored"
--            Errored.view session subModel
                |> frame Page.Other

        Login subModel ->
            Login.view subModel
                |> frame Page.Login
                |> Html.map LoginMsg

        NotFound ->
--            NotFound.view session
            NotFound.view
                |> frame Page.Other

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


main : Program Flags Model Msg
main =
    Navigation.programWithFlags ( Route.fromLocation >> SetRoute )
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


