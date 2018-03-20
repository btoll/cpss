module Main exposing (..)

import Data.BillSheet exposing (BillSheet)
import Data.Consumer exposing (Consumer)
import Data.County exposing (County)
import Data.DIA exposing (DIA)
import Data.Session exposing (Session)
import Data.ServiceCode exposing (ServiceCode)
import Data.Status exposing (Status)
import Data.TimeEntry exposing (TimeEntry)
import Data.User exposing (User)
import Html exposing (Html, text)
import Http
import Navigation
import Page.BillSheet as BillSheet
import Page.Consumer as Consumer
import Page.County as County
import Page.DIA as DIA
import Page.Login as Login
import Page.NotFound as NotFound
import Page.ServiceCode as ServiceCode
import Page.Specialist as Specialist
import Page.Status as Status
import Page.TimeEntry as TimeEntry
import Ports exposing (SessionCredentials, getSessionCredentials, setSessionCredentials)
import Request.Specialist
import Route exposing (Route)
import Task
import Views.Page as Page exposing (ActivePage)



type alias Build =
    { url : String
    }


type alias Flags =
    { env : Maybe String
    }


type Page
    = Blank
    | NotFound
    | Errored String
    | BillSheet BillSheet.Model
    | Consumer Consumer.Model
    | County County.Model
    | DIA DIA.Model
    | Login Login.Model
    | ServiceCode ServiceCode.Model
    | Specialist Specialist.Model
    | Status Status.Model
    | TimeEntry TimeEntry.Model



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
        { session =
            { user = Nothing
            , sessionName = ""
            , expiry = ""
            }
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
    | CountyMsg County.Msg
    | DIAMsg DIA.Msg
    | LoginMsg Login.Msg
    | ServiceCodeMsg ServiceCode.Msg
    | SpecialistMsg Specialist.Msg
    | StatusMsg Status.Msg
    | TimeEntryMsg TimeEntry.Msg
    | ReadSessionCredentials SessionCredentials
    | FetchedUserSession ( Result Http.Error User )



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

        Just Route.County ->
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
                                    County.init model.build.url
                            in
                            { model |
                                page = County subModel
                            } ! [ Cmd.map CountyMsg subMsg ]

                        _ ->
                            { model | page = Errored "You are not authorized to view this page" } ! []

        Just Route.DIA ->
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
                                    DIA.init model.build.url
                            in
                            { model |
                                page = DIA subModel
                            } ! [ Cmd.map DIAMsg subMsg ]

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
                    session = { session |
                        user = Nothing
                        , sessionName = ""
                        , expiry = ""
                        }
                    , page = Login Login.init
                    , onLogin = Just Route.Home
                } ! [ Route.Login |> Route.modifyUrl
                    , setSessionCredentials             -- Send session credentials to JavaScript to be put into local storage to complete logout.
                        { userID = ""
                        , sessionName = ""
                        , expiry = ""
                        }
                    ]

        Just Route.ServiceCode ->
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
                                    ServiceCode.init model.build.url
                            in
                            { model |
                                page = ServiceCode subModel
                            } ! [ Cmd.map ServiceCodeMsg subMsg ]

                        _ ->
                            { model | page = Errored "You are not authorized to view this page" } ! []

        Just Route.Specialist ->
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

                Just user ->
                    case user.authLevel of
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

        Just Route.TimeEntry ->
            case model.session.user of
                Nothing ->
                    { model |
                        page = Login Login.init
                        , onLogin = maybeRoute
                    } ! []

                Just user ->
                    case user.authLevel of
                        2 ->
                            let
                                ( subModel, subMsg ) =
                                    TimeEntry.init model.build.url model.session
                            in
                            { model |
                                page = TimeEntry subModel
                            } ! [ Cmd.map TimeEntryMsg subMsg ]

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

        ( CountyMsg subMsg, County subModel ) ->
            toPage County CountyMsg County.update subMsg subModel

        ( DIAMsg subMsg, DIA subModel ) ->
            toPage DIA DIAMsg DIA.update subMsg subModel

        ( FetchedUserSession ( Ok user ), _ ) ->
            let
                oldSession = model.session
            in
            { model |
                session =
                    { oldSession |
                        user = user |> Just
                    }
            } |> setRoute model.onLogin

        ( FetchedUserSession ( Err err ), _ ) ->
            model ! []

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

                                ( m, routeCmd ) =
                                    { model |
                                        session =
                                            { user = Just user
                                            , sessionName = ""
                                            , expiry = ""
                                            }
                                        , page = Blank
                                        , onLogin = Nothing
                                    } |> setRoute model.onLogin     -- Redirect after logging in.
                            in
                            m ! [ routeCmd
                                , setSessionCredentials             -- Send session credentials to JavaScript to be put into local storage.
                                    { userID = user.id |> toString
                                    , sessionName = "derp"  -- TODO
                                    , expiry = "?"          -- TODO
                                    }
                                ]
            in
            ( newModel, newCmd )

        ( ReadSessionCredentials session, _ ) ->
            let
                oldSession = model.session

                cmd =
                    if (/=) session.userID "" then
                        session.userID
                            |> Request.Specialist.get model.build.url
                            |> Http.send FetchedUserSession
                    else Cmd.none
            in
            { model |
                session =
                    { oldSession |
                        sessionName = session.sessionName
                        , expiry = session.expiry
                    }
            } ! [ cmd ]

        ( ServiceCodeMsg subMsg, ServiceCode subModel ) ->
            toPage ServiceCode ServiceCodeMsg ServiceCode.update subMsg subModel

        ( SpecialistMsg subMsg, Specialist subModel ) ->
            toPage Specialist SpecialistMsg Specialist.update subMsg subModel

        ( StatusMsg subMsg, Status subModel ) ->
            toPage Status StatusMsg Status.update subMsg subModel

        ( TimeEntryMsg subMsg, TimeEntry subModel ) ->
            toPage TimeEntry TimeEntryMsg TimeEntry.update subMsg subModel

        _ ->
            model ! []

-- VIEW


view : Model -> Html Msg
view model =
    let
        frame =
--            Page.frame isLoading session.user
            Page.frame

        session = model.session
    in
    case model.page of
        Blank ->
            -- This is for the very initial page load, while we are loading
            -- data via HTTP. We could also render a spinner here.
            text ""
                |> frame session.user Page.Home

        BillSheet subModel ->
            BillSheet.view subModel
                |> frame session.user Page.BillSheet
                |> Html.map BillSheetMsg

        Consumer subModel ->
            Consumer.view subModel
                |> frame session.user Page.Consumer
                |> Html.map ConsumerMsg

        County subModel ->
            County.view subModel
                |> frame session.user Page.County
                |> Html.map CountyMsg

        DIA subModel ->
            DIA.view subModel
                |> frame session.user Page.DIA
                |> Html.map DIAMsg

        Errored err ->
            text err
                |> frame session.user Page.Other

        Login subModel ->
            Login.view subModel
                |> frame session.user Page.Login
                |> Html.map LoginMsg

        NotFound ->
            NotFound.view
                |> frame session.user Page.Other

        ServiceCode subModel ->
            ServiceCode.view subModel
                |> frame session.user Page.ServiceCode
                |> Html.map ServiceCodeMsg

        Specialist subModel ->
            Specialist.view subModel
                |> frame session.user Page.Specialist
                |> Html.map SpecialistMsg

        Status subModel ->
            Status.view subModel
                |> frame session.user Page.Status
                |> Html.map StatusMsg

        TimeEntry subModel ->
            TimeEntry.view subModel
                |> frame model.session.user Page.TimeEntry
                |> Html.map TimeEntryMsg



-- MAIN --


main : Program Flags Model Msg
main =
    Navigation.programWithFlags ( Route.fromLocation >> SetRoute )
        { init = init
        , update = update
        , view = view
        , subscriptions = ( \m -> ReadSessionCredentials |> getSessionCredentials )
        }


