module Page.Specialist exposing (Model, Msg, init, update, view)

import Data.Specialist exposing (Specialist)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Specialist
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Form as Form



-- MODEL


type alias Model =
    -- NOTE: Order matters here (see `init`)!
    { tableState : Table.State
    , action : Action
    , editing : Maybe Specialist
    , disabled : Bool
    , specialists : List Specialist
    }


type Action = None | Adding | ChangingPassword | Editing

init : String -> Task Http.Error Model
init url =
    Request.Specialist.get url
        |> Http.toTask
        |> Task.map ( Model ( Table.initialSort "ID" ) None Nothing True )



-- UPDATE


type Msg
    = Add
    | Cancel
    | ChangePassword Specialist
    | Delete Specialist
    | Deleted ( Result Http.Error Specialist )
    | Edit Specialist
    | Getted ( Result Http.Error ( List Specialist ) )
    | Post
    | Posted ( Result Http.Error Specialist )
    | Put
    | Putted ( Result Http.Error Int )
    | SetFormValue ( String -> Specialist ) String
    | SetTableState Table.State
    | Submit
    | ToggleSelected Int


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update url msg model =
    case msg of
        Add ->
            { model |
                action = Adding
                , editing = Nothing
            } ! []

        Cancel ->
            { model |
                action = None
                , editing = Nothing
            } ! []

        ChangePassword specialist ->
            { model |
                action = ChangingPassword
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
            model ! []

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
                , tableState = Table.initialSort "ID"
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
                                |> (::) { newSpecialist | id = specialist.id , password = specialist.password }
            in
                { model |
                    specialists = specialists
                    , editing = Nothing
                } ! []

        Posted ( Err err ) ->
            { model |
                editing = Nothing
            } ! []

        Put ->
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

        Putted ( Ok id ) ->
            let
                specialists =
                    case model.editing of
                        Nothing ->
                            model.specialists

                        Just newSpecialist ->
                            model.specialists
                                |> (::) { newSpecialist | id = id }
                newSpecialist =
                    case model.editing of
                        -- TODO
                        Nothing ->
                            Specialist -1 "" "" "" "" "" 0.00 1 False

                        Just specialist ->
                            specialist
            in
                { model |
                    specialists =
                        model.specialists
                            |> List.filter ( \m -> newSpecialist.id /= m.id )
                            |> (::) newSpecialist
                    , editing = Nothing
                } ! []

        Putted ( Err err ) ->
            { model |
                editing = Nothing
            } ! []

        SetFormValue setFormValue s ->
            { model |
                editing = Just ( setFormValue s )
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

        ToggleSelected id ->
            { model |
                specialists =
                    model.specialists
                        |> List.map ( toggle ( toString id ) )
            } ! []


toggle : String -> Specialist -> Specialist
toggle id specialist =
    if ( (==) ( toString specialist.id ) id ) then
        { specialist | selected = not specialist.selected }
    else
        specialist



-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (::)
            ( h1 [] [ text "Specialists" ] )
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView { action, disabled, editing, tableState, specialists } =
    let
        editable : Specialist
        editable = case editing of
            Nothing ->
                Specialist -1 "" "" "" "" "" 0.00 1 False

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
                    Form.textRow "Username" editable.username ( SetFormValue (\v -> { editable | username = v }) )
                    , Form.textRow "Password" editable.password ( SetFormValue (\v -> { editable | password = v }) )
                    , Form.textRow "First Name" editable.firstname ( SetFormValue (\v -> { editable | firstname = v }) )
                    , Form.textRow "Last Name" editable.lastname ( SetFormValue (\v -> { editable | lastname = v }) )
                    , Form.textRow "Email" editable.email ( SetFormValue (\v -> { editable | email = v }) )
                    , Form.floatRow "Pay Rate" ( toString editable.payrate ) ( SetFormValue (\v -> { editable | payrate = ( Result.withDefault 0.00 ( String.toFloat v ) ) } ) )
                    , Form.textRow "Auth Level" ( toString editable.authLevel ) ( SetFormValue (\v -> { editable | authLevel = ( Result.withDefault -1 ( String.toInt v ) ) } ) )
                    , Form.submitRow disabled Cancel
                    ]
                ]

            ChangingPassword ->
                [ form [ onSubmit Put ] [
                    Form.hiddenTextRow "Username" editable.username
                    , Form.disabledTextRow "Password" editable.password ( SetFormValue (\v -> { editable | password = v }) )
                    , Form.hiddenTextRow "First Name" editable.firstname
                    , Form.hiddenTextRow "Last Name" editable.lastname
                    , Form.hiddenTextRow "Email" editable.email
                    , Form.hiddenTextRow "Pay Rate" ( toString editable.payrate )
                    , Form.submitRow disabled Cancel
                    ]
                ]

            Editing ->
                [ form [ onSubmit Put ] [
                    Form.disabledTextRow "ID" ( toString editable.id ) ( SetFormValue (\v -> { editable | id = ( Result.withDefault -1 ( String.toInt v ) ) }) )
                    , Form.textRow "Username" editable.username ( SetFormValue (\v -> { editable | username = v }) )
                    , Form.disabledTextRow "Password" editable.password ( SetFormValue (\v -> { editable | password = v }) )
                    , Form.textRow "First Name" editable.firstname ( SetFormValue (\v -> { editable | firstname = v }) )
                    , Form.textRow "Last Name" editable.lastname ( SetFormValue (\v -> { editable | lastname = v }) )
                    , Form.textRow "Email" editable.email ( SetFormValue (\v -> { editable | email = v }) )
                    , Form.floatRow "Pay Rate" ( toString editable.payrate ) ( SetFormValue (\v -> { editable | payrate = ( Result.withDefault 0.00 ( String.toFloat v ) ) }) )
                    , Form.textRow "Auth Level" ( toString editable.authLevel ) ( SetFormValue (\v -> { editable | authLevel = ( Result.withDefault -1 ( String.toInt v ) ) } ) )
                    , Form.submitRow disabled Cancel
                    ]
                ]


-- TABLE CONFIGURATION


config : Table.Config Specialist Msg
config =
    Table.customConfig
    -- TODO: Figure out why .id is giving me trouble!
--    { toId = .id
    { toId = .username
    , toMsg = SetTableState
    , columns =
        [ customColumn viewCheckbox
        , Table.intColumn "ID" .id
        , Table.stringColumn "Username" .username
        , Table.stringColumn "Password" ( .password >> String.slice 0 10 )       -- Just show a small portion of the hashed password.
        , Table.stringColumn "First Name" .firstname
        , Table.stringColumn "Last Name" .lastname
        , Table.stringColumn "Email" .email
        , Table.floatColumn "Pay Rate" .payrate
        , Table.intColumn "Auth Level" .authLevel
        , customColumn viewButton
        , customColumn viewButton2
        , customColumn viewButton3
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : Specialist -> List ( Attribute Msg )
toRowAttrs { id, selected } =
    [ onClick ( ToggleSelected id )
    , style [ ( "background", if selected then "#CEFAF8" else "white" ) ]
    ]


customColumn : ( Specialist -> Table.HtmlDetails Msg ) -> Table.Column Specialist Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


-- TODO: Dry!
viewButton : Specialist -> Table.HtmlDetails Msg
viewButton specialist =
    Table.HtmlDetails []
        [ button [ onClick ( Edit specialist ) ] [ text "Edit" ]
        ]

viewButton2 : Specialist -> Table.HtmlDetails Msg
viewButton2 specialist =
    Table.HtmlDetails []
        [ button [ onClick ( Delete specialist ) ] [ text "Delete" ]
        ]

viewButton3 : Specialist -> Table.HtmlDetails Msg
viewButton3 specialist =
    Table.HtmlDetails []
        [ button [ onClick ( ChangePassword specialist ) ] [ text "Change Password" ]
        ]

viewCheckbox : Specialist -> Table.HtmlDetails Msg
viewCheckbox { selected } =
    Table.HtmlDetails []
        [ input [ type_ "checkbox", checked selected ] []
        ]
------------


