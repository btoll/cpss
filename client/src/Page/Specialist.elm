module Page.Specialist exposing (Model, Msg, init, update, view)

import Data.User as User exposing (User)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Session
import Request.Specialist
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Form as Form
import Views.Errors as Errors



-- MODEL


type alias Model =
    -- NOTE: Order matters here (see `init`)!
    { errors : List String
    , tableState : Table.State
    , action : Action
    , editing : Maybe User
    , disabled : Bool
    , changingPassword : String         -- Use for both storing current password and new password when changing password!
    , specialists : List User
    }


type Action
    = None
    | Adding
    | ChangingPassword User
    | Editing
    | SettingPassword User

init : String -> Task Http.Error Model
init url =
    Request.Specialist.get url
        |> Http.toTask
        |> Task.map ( Model [] ( Table.initialSort "ID" ) None Nothing True "" )



-- UPDATE


type Msg
    = Add
    | Authenticated User ( Result Http.Error User )
    | Cancel
    | ChangePassword User
    | Delete User
    | Deleted ( Result Http.Error User )
    | Edit User
    | Getted ( Result Http.Error ( List User ) )
    | Hashed ( Result Http.Error User )
    | Post
    | Posted ( Result Http.Error User )
    | Put Action
    | Putted ( Result Http.Error User )
    | SetPasswordValue String
    | SetTextValue ( String -> User ) String
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
                , errors = [ "Passwords do not match!" ]
            } ! []

        Cancel ->
            { model |
                action = None
                , editing = Nothing
                , errors = []
            } ! []

        ChangePassword specialist ->
            { model |
                action = ChangingPassword specialist
                , editing = Just specialist
            } ! []

        Delete specialist ->
            let
                subCmd =
                    Request.Specialist.delete url specialist
                        |> Http.toTask
                        |> Task.attempt Deleted
            in
                { model |
                    action = None
                    , editing = Nothing
                } ! [ subCmd ]

        Deleted ( Ok deletedSpecialist ) ->
            { model |
                specialists = model.specialists |> List.filter ( \m -> deletedSpecialist.id /= m.id )
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

        Getted ( Ok specialists ) ->
            { model |
                specialists = specialists
                , tableState = Table.initialSort "ID"
            } ! []

        Getted ( Err err ) ->
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

        Post ->
            let
                subCmd = case model.editing of
                    Nothing ->
                        Cmd.none

                    Just specialist ->
                        Request.Specialist.post url specialist
                            |> Http.toTask
                            |> Task.attempt Posted
            in
                { model |
                    action = None
                } ! [ subCmd ]

        Posted ( Ok specialist ) ->
            let
                specialists =
                    case model.editing of
                        Nothing ->
                            model.specialists

                        Just newSpecialist ->
                            model.specialists
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

        Posted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be saved!" model.errors
            } ! []

        Put action ->
            case action of
                Editing ->
                    let
                        subCmd = case model.editing of
                            Nothing ->
                                Cmd.none

                            Just specialist ->
                                Request.Specialist.put url specialist
                                    |> Http.toTask
                                    |> Task.attempt Putted
                    in
                        { model |
                            action = None
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

        SetPasswordValue s ->
            { model |
                changingPassword = s
                , disabled = False
            } ! []

        SetTableState newState ->
            { model | tableState = newState
            } ! []

        SetTextValue setTextValue s ->
            { model |
                editing = Just ( setTextValue s )
                , disabled = False
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
        editable : User
        editable = case editing of
            Nothing ->
                User -1 "" "" "" "" "" 0.00 1

            Just specialist ->
                specialist
    in
        case action of
            None ->
                [ button [ onClick Add ] [ text "Add Specialist" ]
                , Table.view config tableState specialists
                ]

            Adding ->
                [ form [ onSubmit Post ] [
                    Form.textRow "Username" editable.username ( SetTextValue (\v -> { editable | username = v }) )
                    , Form.textRow "Password" editable.password ( SetTextValue (\v -> { editable | password = v }) )
                    , Form.textRow "First Name" editable.firstname ( SetTextValue (\v -> { editable | firstname = v }) )
                    , Form.textRow "Last Name" editable.lastname ( SetTextValue (\v -> { editable | lastname = v }) )
                    , Form.textRow "Email" editable.email ( SetTextValue (\v -> { editable | email = v }) )
                    , Form.floatRow "Pay Rate" ( toString editable.payrate ) ( SetTextValue (\v -> { editable | payrate = ( Result.withDefault 0.00 ( String.toFloat v ) ) } ) )
                    , Form.textRow "Auth Level" ( toString editable.authLevel ) ( SetTextValue (\v -> { editable | authLevel = ( Result.withDefault -1 ( String.toInt v ) ) } ) )
                    , Form.submitRow disabled Cancel
                    ]
                ]

            ChangingPassword editable ->
                [ form [ onSubmit ( Put ( ChangingPassword editable ) ) ] [
                    Form.textRow "Current Password" model.changingPassword SetPasswordValue
                    , Form.submitRow disabled Cancel
                    ]
                ]

            Editing ->
                [ form [ onSubmit ( Put Editing ) ] [
                    Form.disabledTextRow "ID" ( toString editable.id ) ( SetTextValue (\v -> { editable | id = ( Result.withDefault -1 ( String.toInt v ) ) }) )
                    , Form.textRow "Username" editable.username ( SetTextValue (\v -> { editable | username = v }) )
                    , Form.disabledTextRow "Password" editable.password ( SetTextValue (\v -> { editable | password = v }) )
                    , Form.textRow "First Name" editable.firstname ( SetTextValue (\v -> { editable | firstname = v }) )
                    , Form.textRow "Last Name" editable.lastname ( SetTextValue (\v -> { editable | lastname = v }) )
                    , Form.textRow "Email" editable.email ( SetTextValue (\v -> { editable | email = v }) )
                    , Form.floatRow "Pay Rate" ( toString editable.payrate ) ( SetTextValue (\v -> { editable | payrate = ( Result.withDefault 0.00 ( String.toFloat v ) ) }) )
                    , Form.textRow "Auth Level" ( toString editable.authLevel ) ( SetTextValue (\v -> { editable | authLevel = ( Result.withDefault -1 ( String.toInt v ) ) } ) )
                    , Form.submitRow disabled Cancel
                    ]
                ]

            SettingPassword specialist ->
                [ form [ onSubmit ( Put ( SettingPassword specialist ) ) ] [
                    Form.textRow "New Password" model.changingPassword  SetPasswordValue
                    , Form.submitRow disabled Cancel
                    ]
                ]


-- TABLE CONFIGURATION


config : Table.Config User Msg
config =
    Table.customConfig
    -- TODO: Figure out why .id is giving me trouble!
--    { toId = .id
    { toId = .username
    , toMsg = SetTableState
    , columns =
        [ Table.intColumn "ID" .id
        , Table.stringColumn "Username" .username
        , Table.stringColumn "Password" ( .password >> String.slice 0 10 )       -- Just show a small portion of the hashed password.
        , Table.stringColumn "First Name" .firstname
        , Table.stringColumn "Last Name" .lastname
        , Table.stringColumn "Email" .email
        , Table.floatColumn "Pay Rate" .payrate
        , Table.intColumn "Auth Level" .authLevel
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        , customColumn ( viewButton ChangePassword "Change Password" )
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : User -> List ( Attribute Msg )
toRowAttrs { id } =
    [ style [ ( "background", "white" ) ]
    ]


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


