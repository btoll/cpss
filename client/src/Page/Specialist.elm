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
    , specialists : List Specialist
    }


type Action = None | Adding | Editing

init : String -> Task Http.Error Model
init url =
    Request.Specialist.get url
        |> Http.toTask
        |> Task.map ( Model ( Table.initialSort "ID" ) None Nothing )



-- UPDATE


type Msg
    = Add
    | Cancel
    | Delete Specialist
    | Deleted ( Result Http.Error () )
    | Edit Specialist
    | Getted ( Result Http.Error ( List Specialist ) )
    | Post
    | Posted ( Result Http.Error Specialist )
    | SetFormValue ( String -> Specialist ) String
    | SetTableState Table.State
    | Submit
    | ToggleSelected String


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

        Deleted ( Ok specialist ) ->
            model ! []

        Deleted ( Err err ) ->
            let
                gg = (Debug.log "err" err)
            in
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
                    , editing = Nothing
                } ! [ subCmd ]

        Posted ( Ok specialist ) ->
            model ! []

        Posted ( Err err ) ->
            model ! []

        SetFormValue setFormValue s ->
            { model | editing = Just ( setFormValue s ) } ! []

        SetTableState newState ->
            { model | tableState = newState
            } ! []

        Submit ->
            { model | action = None } ! []

        ToggleSelected id ->
            { model |
                specialists =
                    model.specialists
                        |> List.map ( toggle id )
            } ! []


toggle : String -> Specialist -> Specialist
toggle id specialist =
    if specialist.id == id then
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
drawView { action, editing, tableState, specialists } =
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Specialist" ]
            , Table.view config tableState specialists
            ]

        -- Adding | Editing
        _ ->
            [ lazy viewForm editing
            ]


viewForm : Maybe Specialist -> Html Msg
viewForm specialist =
    let
        editable : Specialist
        editable = case specialist of
            Nothing ->
                Specialist "-1" "" "" "" "" "" 0.00 False

            Just specialist ->
                specialist
    in
        form [ onSubmit Post ] [
            Form.disabledTextRow "ID" editable.id ( SetFormValue (\v -> { editable | id = v }) )
            , Form.textRow "Username" editable.username ( SetFormValue (\v -> { editable | username = v }) )
            , Form.textRow "Password" editable.password ( SetFormValue (\v -> { editable | password = v }) )
            , Form.textRow "First Name" editable.firstname ( SetFormValue (\v -> { editable | firstname = v }) )
            , Form.textRow "Last Name" editable.lastname ( SetFormValue (\v -> { editable | lastname = v }) )
            , Form.textRow "Email" editable.email ( SetFormValue (\v -> { editable | email = v }) )
            , Form.stepRow "Pay Rate" ( toString editable.payrate ) ( SetFormValue (\v -> { editable | payrate = ( Result.withDefault 0.00 ( String.toFloat v ) ) }) )
            , Form.submitRow False Cancel
        ]


-- TABLE CONFIGURATION


config : Table.Config Specialist Msg
config =
    Table.customConfig
    { toId = .id
    , toMsg = SetTableState
    , columns =
        [ customColumn viewCheckbox
        , Table.stringColumn "ID" .id
        , Table.stringColumn "Username" .username
        , Table.stringColumn "Password" .password
        , Table.stringColumn "First Name" .firstname
        , Table.stringColumn "Last Name" .lastname
        , Table.stringColumn "Email" .email
        , Table.floatColumn "Pay Rate" .payrate
        , customColumn viewButton
        , customColumn viewButton2
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

viewCheckbox : Specialist -> Table.HtmlDetails Msg
viewCheckbox { selected } =
    Table.HtmlDetails []
        [ input [ type_ "checkbox", checked selected ] []
        ]
------------


