module Main exposing (..)

import Data.BillSheet exposing (BillSheet)
import Data.Consumer exposing (Consumer)
import Data.Session exposing (Session)
import Data.Status exposing (Status)
import Data.User exposing (User)
import Html exposing (Html, text)
import Http
import Navigation
import Page.BillSheet as BillSheet
import Page.Consumer as Consumer
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Specialist as Specialist
import Page.Status as Status
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
    | Errored String
--    | Home Home.Model
    | BillSheet BillSheet.Model
    | Consumer Consumer.Model
    | Login Login.Model
    | Specialist Specialist.Model
    | Status Status.Model



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
            then "http://96.31.87.245/cpss"
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
    | BillSheetMsg BillSheet.Msg
    | ConsumerMsg Consumer.Msg
    | LoginMsg Login.Msg
    | SpecialistMsg Specialist.Msg
    | StatusLoaded ( Result Http.Error Status.Model )
    | StatusMsg Status.Msg


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    case maybeRoute of
        Just Route.BillSheet ->
            case model.session.user of
                Nothing ->
                    { model |
                        page = Login Login.init
                        , onLogin = maybeRoute
                    } ! []

                Just user ->
                    case user.authLevel of
                        1 ->
                            let
                                ( subModel, subMsg ) =
                                    BillSheet.init model.build.url
                            in
                                { model |
                                    page = BillSheet subModel
                                } ! [ Cmd.map BillSheetMsg subMsg ]

                        _ ->
                            { model | page = Errored "You are not authorized to view this page" } ! []

        Just Route.Consumer ->
            case model.session.user of
                Nothing ->
                    { model |
                        page = Login Login.init
                        , onLogin = maybeRoute
                    } ! []

                Just user ->
                    case user.authLevel of
                        1 ->
                            let
                                ( subModel, subMsg ) =
                                    Consumer.init model.build.url
                            in
                                { model |
                                    page = Consumer subModel
                                } ! [ Cmd.map ConsumerMsg subMsg ]

                        _ ->
                            { model | page = Errored "You are not authorized to view this page" } ! []

        Just Route.Home ->
            case model.session.user of
                Nothing ->
                    { model |
                        page = Login Login.init
                        , onLogin = maybeRoute
                    } ! []

                Just user ->
                    { model | page = Blank } ! []

        Just Route.Login ->
            case model.session.user of
                Nothing ->
                    { model |
                        page = Login Login.init
                        , onLogin = Just Route.Home
                    } ! []

                -- TODO: Not sure it ever matches Just!!
                Just user ->
                    { model | page = Blank } ! [ Route.Home |> Route.modifyUrl ]

        Just Route.Logout ->
            let
                session = model.session
            in
                { model |
                    session = { session | user = Nothing }
                    , page = Login Login.init
                    , onLogin = Just Route.Home
                } ! [ Route.Login |> Route.modifyUrl ]

        Just Route.Specialist ->
            case model.session.user of
                Nothing ->
                    { model |
                        page = Login Login.init
                        , onLogin = maybeRoute
                    } ! []

                Just specialist ->
                    case specialist.authLevel of
                        1 ->
                            let
                                ( subModel, subMsg ) =
                                    Specialist.init model.build.url
                            in
                                { model |
                                    page = Specialist subModel
                                } ! [ Cmd.map SpecialistMsg subMsg ]

                        _ ->
                            { model | page = Errored "You are not authorized to view this page" } ! []

        Just Route.Status ->
            case model.session.user of
                Nothing ->
                    { model |
                        page = Login Login.init
                        , onLogin = maybeRoute
                    } ! []

                Just status ->
                    case status.authLevel of
                        1 ->
                            let
                                ( subModel, subMsg ) =
                                    Status.init model.build.url
                            in
                                { model |
                                    page = Status subModel
                                } ! [ Cmd.map StatusMsg subMsg ]

                        _ ->
                            { model | page = Errored "You are not authorized to view this page" } ! []

        Nothing ->
            case model.session.user of
                Nothing ->
                    { model | page = Login Login.init } ! []

                Just _ ->
                    { model | page = Errored "404: Page not found." } ! []


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

            ( BillSheetMsg subMsg, BillSheet subModel ) ->
                toPage BillSheet BillSheetMsg BillSheet.update subMsg subModel

            ( ConsumerMsg subMsg, Consumer subModel ) ->
                toPage Consumer ConsumerMsg Consumer.update subMsg subModel

            ( LoginMsg subMsg, Login subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Login.update model.build.url subMsg subModel

                    ( newModel, newCmd ) =
                        case msgFromPage of
                            Login.NoOp ->
                                ( { model | page = Login pageModel }, Cmd.map LoginMsg cmd )

                            Login.SetUser user ->
                                let
                                    session =
                                        model.session
                                in
                                    { model |
                                        session = { user = Just user }
                                        , page = Blank
                                        , onLogin = Nothing
                                    } |> setRoute model.onLogin     -- Redirect after logging in.
                in
                    ( newModel, newCmd )

            ( SpecialistMsg subMsg, Specialist subModel ) ->
                toPage Specialist SpecialistMsg Specialist.update subMsg subModel

            ( StatusMsg subMsg, Status subModel ) ->
                toPage Status StatusMsg Status.update subMsg subModel

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
            text ""
                |> frame model.session.user Page.Home

        BillSheet subModel ->
            BillSheet.view subModel
                |> frame model.session.user Page.BillSheet
                |> Html.map BillSheetMsg

        Consumer subModel ->
            Consumer.view subModel
                |> frame model.session.user Page.Consumer
                |> Html.map ConsumerMsg

        Errored err ->
            text err
                |> frame model.session.user Page.Other

        Login subModel ->
            Login.view subModel
                |> frame model.session.user Page.Login
                |> Html.map LoginMsg

        NotFound ->
            NotFound.view
                |> frame model.session.user Page.Other

        Specialist subModel ->
            Specialist.view subModel
                |> frame model.session.user Page.Specialist
                |> Html.map SpecialistMsg

        Status subModel ->
            Status.view subModel
                |> frame model.session.user Page.Status
                |> Html.map StatusMsg

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


