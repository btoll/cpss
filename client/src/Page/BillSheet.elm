module Page.BillSheet exposing (Model, Msg, init, update, view)

import Data.BillSheet exposing (BillSheet)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.BillSheet
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Form as Form



-- MODEL


type alias Model =
    -- NOTE: Order matters here (see `init`)!
    { tableState : Table.State
    , action : Action
    , editing : Maybe BillSheet
    , disabled : Bool
    , billsheets : List BillSheet
    }


type Action = None | Adding | Editing

init : String -> Task Http.Error Model
init url =
    Request.BillSheet.get url
        |> Http.toTask
        |> Task.map ( Model ( Table.initialSort "ID" ) None Nothing True )



-- UPDATE


type Msg
    = Add
    | Cancel
    | Delete BillSheet
    | Deleted ( Result Http.Error () )
    | Edit BillSheet
    | Getted ( Result Http.Error ( List BillSheet ) )
    | Post
    | Posted ( Result Http.Error BillSheet )
    | SetFormValue ( String -> BillSheet ) String
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

        Cancel ->
            { model |
                action = None
                , editing = Nothing
            } ! []

        Delete billsheet ->
            let
                subCmd =
                    Request.BillSheet.delete url billsheet
                        |> Http.toTask
                        |> Task.attempt Deleted
            in
                { model |
                    action = None
                    , editing = Nothing
                } ! [ subCmd ]

        Deleted ( Ok billsheet ) ->
            model ! []

        Deleted ( Err err ) ->
            let
                gg = (Debug.log "err" err)
            in
            model ! []

        Edit billsheet ->
            { model |
                action = Editing
                , editing = Just billsheet
            } ! []

        Getted ( Ok billsheets ) ->
            { model |
                billsheets = billsheets
                , tableState = Table.initialSort "ID"
            } ! []

        Getted ( Err err ) ->
            { model |
                billsheets = []
                , tableState = Table.initialSort "ID"
            } ! []

        Post ->
            let
                subCmd = case model.editing of
                    Nothing ->
                        Cmd.none

                    Just billsheet ->
                        Request.BillSheet.post url billsheet
                            |> Http.toTask
                            |> Task.attempt Posted
            in
                { model |
                    action = None
                    , editing = Nothing
                } ! [ subCmd ]

        Posted ( Ok billsheet ) ->
            model ! []

        Posted ( Err err ) ->
            model ! []

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



-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (::)
            ( h1 [] [ text "Bill Sheet" ] )
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView ( { action, editing, tableState, billsheets } as model ) =
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Bill Sheet" ]
            , Table.view config tableState billsheets
            ]

        -- Adding | Editing
        _ ->
            [ lazy viewForm model
            ]


viewForm : Model -> Html Msg
viewForm { editing, disabled }  =
    let
        editable : BillSheet
        editable = case editing of
            Nothing ->
                BillSheet "" "" "" 0.00 "" "" "" "" "" "" "" False

            Just billsheet ->
                billsheet
    in
        form [ onSubmit Post ] [
            Form.disabledTextRow "ID" editable.id ( SetFormValue (\v -> { editable | id = v }) )
            , Form.textRow "Recipient ID" editable.recipientID ( SetFormValue (\v -> { editable | recipientID = v }) )
            , Form.textRow "Service Date" editable.serviceDate ( SetFormValue (\v -> { editable | serviceDate = v }) )
            , Form.floatRow "Billed Amount" ( toString editable.billedAmount ) ( SetFormValue (\v -> { editable | billedAmount = ( Result.withDefault 0.00 ( String.toFloat v ) ) }) )
            , Form.textRow "Consumer" editable.consumer ( SetFormValue (\v -> { editable | consumer = v }) )
            , Form.textRow "Status" editable.status ( SetFormValue (\v -> { editable | status = v }) )
            , Form.textRow "Confirmation" editable.confirmation ( SetFormValue (\v -> { editable | confirmation = v }) )
            , Form.textRow "Service" editable.service ( SetFormValue (\v -> { editable | service = v }) )
            , Form.textRow "County" editable.county ( SetFormValue (\v -> { editable | county = v }) )
            , Form.textRow "Specialist" editable.specialist ( SetFormValue (\v -> { editable | specialist = v }) )
            , Form.textRow "Record Number" editable.recordNumber ( SetFormValue (\v -> { editable | recordNumber = v }) )
            , Form.submitRow disabled Cancel
        ]


-- TABLE CONFIGURATION


config : Table.Config BillSheet Msg
config =
    Table.customConfig
    { toId = .id
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "ID" .id
        , Table.stringColumn "Recipient ID" .recipientID
        , Table.stringColumn "Service Date" .serviceDate
        , Table.floatColumn "Billed Amount" .billedAmount
        , Table.stringColumn "Consumer" .consumer
        , Table.stringColumn "Status" .status
        , Table.stringColumn "Confirmation" .confirmation
        , Table.stringColumn "Service" .service
        , Table.stringColumn "County" .county
        , Table.stringColumn "Specialist" .specialist
        , Table.stringColumn "Record Number" .recordNumber
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : BillSheet -> List ( Attribute Msg )
toRowAttrs { id } =
    [ style [ ( "background", "white" ) ]
    ]


customColumn : ( BillSheet -> Table.HtmlDetails Msg ) -> Table.Column BillSheet Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( BillSheet -> msg ) -> String -> BillSheet -> Table.HtmlDetails msg
viewButton msg name billsheet =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| billsheet ] [ text name ]
        ]


