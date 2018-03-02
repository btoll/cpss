module Page.Specialist exposing (Model, Msg, init, update, view)

import Data.Pager exposing (Pager)
import Data.User as User exposing (User, UserWithPager, new)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, for, id, step, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Request.Session
import Request.Specialist
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Validate.Specialist
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal
import Views.Pager



-- MODEL


type alias Model =
    { errors : List ( Validate.Specialist.Field, String )
    , tableState : Table.State
    , action : Action
    , editing : Maybe User
    , disabled : Bool
    , changingPassword : String         -- Use for both storing current password and new password when changing password!
    , showModal : ( Bool, Maybe Modal.Modal )
    , specialists : List User
    , pager : Pager
    }


type Action
    = None
    | Adding
    | ChangingPassword User
    | Editing
    | SettingPassword User


init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , changingPassword = ""         -- Use for both storing current password and new password when changing password!
    , showModal = ( False, Nothing )
    , specialists = []
    , pager = Data.Pager.new
    } ! [ 0 |> Request.Specialist.page url |> Http.send FetchedSpecialists ]



-- UPDATE


type Msg
    = Add
    | Authenticated User ( Result Http.Error User )
    | Cancel
    | ChangePassword User
    | Delete User
    | Deleted ( Result Http.Error User )
    | Edit User
    | FetchedSpecialists ( Result Http.Error UserWithPager )
    | Hashed ( Result Http.Error User )
    | ModalMsg Modal.Msg
    | PagerMsg Views.Pager.Msg
    | Post
    | Posted ( Result Http.Error User )
    | Put Action
    | Putted ( Result Http.Error User )
    | SetFormValue ( String -> User ) String
    | SetPasswordValue String
    | SetTableState Table.State
    | Submit


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update url msg model =
    case msg of
        Add ->
            { model |
                action = Adding
                , editing = Nothing
            } ! []

        Authenticated specialist ( Ok user ) ->
            { model |
                action = SettingPassword specialist
                , errors = []
            } ! []

        Authenticated specialist ( Err err ) ->
            { model |
                action = ChangingPassword specialist
                -- TODO!
--                , errors = [ None, "Passwords do not match!" ]
            } ! []

        Cancel ->
            { model |
                action = None
                , changingPassword = ""
                , disabled = True
                , editing = Nothing
                , errors = []
            } ! []

        ChangePassword specialist ->
            { model |
                action = ChangingPassword specialist
                , editing = Just specialist
            } ! []

        Delete specialist ->
            { model |
                editing = Just specialist
                , showModal = ( True , Modal.Delete |> Just )
            } ! []

        Deleted ( Ok specialist ) ->
            { model |
                specialists = model.specialists |> List.filter ( \m -> specialist.id /= m.id )
            } ! []

        Deleted ( Err err ) ->
            { model |
                action = None
--                , errors = (::) "There was a problem, the record could not be deleted!" model.errors
            } ! []

        Edit specialist ->
            { model |
                action = Editing
                , editing = Just specialist
            } ! []

        FetchedSpecialists ( Ok specialists ) ->
            { model |
                specialists = specialists.users
                , pager = specialists.pager
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedSpecialists ( Err err ) ->
            { model |
                specialists = []
--                , errors = (::) "There was a problem, the record(s) could not be retrieved!" model.errors
                , tableState = Table.initialSort "ID"
            } ! []

        Hashed ( Ok specialist ) ->
            let
                newSpecialist =
                    case model.editing of
                        Nothing ->
                            specialist

                        Just current ->
                            { current | password = specialist.password }

                subCmd =
                    Request.Specialist.put url newSpecialist
                        |> Http.toTask
                        |> Task.attempt Putted
            in
                { model |
                    action = None
                } ! [ subCmd ]

        Hashed ( Err err ) ->
            let
                e = (Debug.log "err" err)
            in
            { model |
                action = None
--                , errors = (::) "There was a problem, the password could not be hashed!" model.errors
            } ! []

        ModalMsg subMsg ->
            let
                cmd =
                    case ( subMsg |> Modal.update ) of
                        False ->
                            Cmd.none

                        True ->
                            Maybe.withDefault new model.editing
                                |> Request.Specialist.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
            in
            { model |
                showModal = ( False, Nothing )
            } ! [ cmd ]

        PagerMsg subMsg ->
            model !
            [ subMsg
                |>Views.Pager.update ( model.pager.currentPage, model.pager.totalPages )
                |> Request.Specialist.page url
                |> Http.send FetchedSpecialists
            ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just specialist ->
                            Validate.Specialist.errors specialist

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just specialist ->
                            ( None
                            , Request.Specialist.post url specialist
                                |> Http.toTask
                                |> Task.attempt Posted
                            )
                    else
                        ( Adding, Cmd.none )
            in
                { model |
                    action = action
                    , editing = Nothing
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok specialist ) ->
            { model |
                specialists = model.specialists |> (::) specialist
                , editing = Nothing
            } ! []

        Posted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be saved!" model.errors
            } ! []

        Put action ->
            case action of
                Editing ->
                    let
                        errors =
                            case model.editing of
                                Nothing ->
                                    []

                                Just specialist ->
                                    Validate.Specialist.errors specialist

                        ( action, subCmd ) = if errors |> List.isEmpty then
                            case model.editing of
                                Nothing ->
                                    ( None, Cmd.none )

                                Just specialist ->
                                    ( None
                                    , Request.Specialist.put url specialist
                                        |> Http.toTask
                                        |> Task.attempt Putted
                                    )
                            else
                                ( Adding, Cmd.none )
                    in
                        { model |
                            action = action
                            , errors = errors
                        } ! [ subCmd ]

                ChangingPassword specialist ->
                    let
                        subCmd =
                            { specialist | password = model.changingPassword }
                                |> Request.Session.auth url
                                    |> Http.toTask
                                    |> Task.attempt ( Authenticated specialist )
                    in
                        { model |
                            action = SettingPassword specialist
                            , changingPassword = ""
                        } ! [ subCmd ]

                SettingPassword specialist ->
                    let
                        subCmd =
                            { specialist | password = model.changingPassword }
                                |> Request.Session.hash url
                                    |> Http.toTask
                                    |> Task.attempt Hashed
                    in
                        { model |
                            action = None
                            , changingPassword = ""
                        } ! [ subCmd ]

                _ ->
                    model ! []

        Putted ( Ok specialist ) ->
            let
                specialists =
                    case model.editing of
                        Nothing ->
                            model.specialists

                        Just newSpecialist ->
                            model.specialists
                                |> List.filter ( \m -> specialist.id /= m.id )
                                |> (::)
                                    { newSpecialist |
                                        id = specialist.id
                                        , password = specialist.password
                                    }
            in
                { model |
                    specialists = specialists
                    , editing = Nothing
                } ! []

        Putted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be updated!" model.errors
            } ! []

        SetFormValue setFormValue s ->
            { model |
                editing = Just ( setFormValue s )
                , disabled = False
            } ! []

        SetPasswordValue s ->
            { model |
                changingPassword = s
                , disabled = False
            } ! []

        SetTableState newState ->
            { model | tableState = newState
            } ! []

        Submit ->
            { model |
                action = None
                , disabled = True
            } ! []



-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (++)
            [ h1 [] [ text "Specialists" ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView (
    { action
    , disabled
    , editing
    , tableState
    , specialists
    } as model ) =
    let
        pager : Pager
        pager =
            model.pager

        editable : User
        editable = case editing of
            Nothing ->
                new

            Just specialist ->
                specialist

        showList =
            case specialists |> List.length of
                0 ->
                    div [] []
                _ ->
                    Table.view config tableState specialists

        showPager : Html Msg
        showPager =
            if 1 |> (>) pager.totalPages then
                pager.currentPage |> Views.Pager.view pager.totalPages |> Html.map PagerMsg
            else
                div [] []
    in
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Specialist" ]
            , showPager
            , showList
            , showPager
            , model.showModal
                |> Modal.view
                |> Html.map ModalMsg
            ]

        Adding ->
            [ form [ onSubmit Post ]
                ( (++)
                    ( editable |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]

        ChangingPassword editable ->
            [ form [ onSubmit ( Put ( ChangingPassword editable ) ) ]
                [ Form.text "Current Password"
                    [ value model.changingPassword
                    , onInput SetPasswordValue
                    ]
                    []
                , Form.submit disabled Cancel
                ]
            ]

        Editing ->
            [ form [ onSubmit ( Put Editing ) ]
                ( (++)
                    ( editable |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]

        SettingPassword specialist ->
            [ form [ onSubmit ( Put ( SettingPassword specialist ) ) ]
                [ Form.text "New Password"
                    [ value model.changingPassword
                    , onInput SetPasswordValue
                    ]
                    []
                , Form.submit disabled Cancel
                ]
            ]


formRows : User -> List ( Html Msg )
formRows editable =
    [ Form.text "Username"
        [ value editable.username
        , onInput ( SetFormValue ( \v -> { editable | username = v } ) )
        , autofocus True
        ]
        []
    , Form.password "Password"
        [ value editable.password
        , onInput ( SetFormValue ( \v -> { editable | password = v } ) )
        ]
        []
    , Form.text "First Name"
        [ value editable.firstname
        , onInput ( SetFormValue (\v -> { editable | firstname = v } ) )
        ]
        []
    , Form.text "Last Name"
        [ value editable.lastname
        , onInput ( SetFormValue (\v -> { editable | lastname = v } ) )
        ]
        []
    , Form.text "Email"
        [ value editable.email
        , onInput ( SetFormValue (\v -> { editable | email = v } ) )
        ]
        []
    , Form.float "Pay Rate"
        [ editable.payrate |> toString |> value
        , onInput ( SetFormValue (\v -> { editable | payrate = Form.toFloat v } ) )
        , step "0.01"
        ]
        []
    , Form.select "Auth Level"
        [ id "authLevelSelection"
        , onInput ( SetFormValue (\v -> { editable | authLevel = Form.toInt v } ) )
        ] (
            [ ( "-1", "-- Select an auth level --" ), ( "1", "Admin" ), ( "2", "User" ) ]
                |> List.map ( editable.authLevel |> toString |> Form.option )
        )
    ]



-- TABLE CONFIGURATION


config : Table.Config User Msg
config =
    Table.customConfig
    { toId = .id >> toString
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Username" .username
        , Table.stringColumn "Password" ( .password >> String.slice 0 10 )       -- Just show a small portion of the hashed password.
        , Table.stringColumn "First Name" .firstname
        , Table.stringColumn "Last Name" .lastname
        , Table.stringColumn "Email" .email
        , Table.floatColumn "Pay Rate" .payrate
        , Table.stringColumn "Auth Level" ( .authLevel >> toString >> ( \s -> if s |> (==) "1" then "Admin" else "User" ) )
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        , customColumn ( viewButton ChangePassword "Change Password" )
        ]
    , customizations = defaultCustomizations
    }


customColumn : ( User -> Table.HtmlDetails Msg ) -> Table.Column User Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( User -> msg ) -> String -> User -> Table.HtmlDetails msg
viewButton msg name specialist =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| specialist ] [ text name ]
        ]


