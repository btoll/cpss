module Page.Consumer exposing (Model, Msg, init, update, view)

import Data.Consumer exposing (Consumer)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Consumer
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Form as Form



-- MODEL


type alias Model =
    -- NOTE: Order matters here (see `init`)!
    { tableState : Table.State
    , action : Action
    , editing : Maybe Consumer
    , consumers : List Consumer
    }


type Action = None | Adding | Editing

init : String -> Task Http.Error Model
init url =
    Request.Consumer.get url
        |> Http.toTask
        |> Task.map ( Model ( Table.initialSort "ID" ) None Nothing )



-- UPDATE


type Msg
    = Add
    | Cancel
    | Delete Consumer
    | Deleted ( Result Http.Error () )
    | Edit Consumer
    | Getted ( Result Http.Error ( List Consumer ) )
    | Post
    | Posted ( Result Http.Error Consumer )
    | SetFormValue ( String -> Consumer ) String
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

        Delete consumer ->
            let
                subCmd =
                    Request.Consumer.delete url consumer
                        |> Http.toTask
                        |> Task.attempt Deleted
            in
                { model |
                    action = None
                    , editing = Nothing
                } ! [ subCmd ]

        Deleted ( Ok consumer ) ->
            model ! []

        Deleted ( Err err ) ->
            let
                gg = (Debug.log "err" err)
            in
            model ! []

        Edit consumer ->
            { model |
                action = Editing
                , editing = Just consumer
            } ! []

        Getted ( Ok consumers ) ->
            { model |
                consumers = consumers
                , tableState = Table.initialSort "ID"
            } ! []

        Getted ( Err err ) ->
            { model |
                consumers = []
                , tableState = Table.initialSort "ID"
            } ! []

        Post ->
            let
                subCmd = case model.editing of
                    Nothing ->
                        Cmd.none

                    Just consumer ->
                        Request.Consumer.post url consumer
                            |> Http.toTask
                            |> Task.attempt Posted
            in
                { model |
                    action = None
                    , editing = Nothing
                } ! [ subCmd ]

        Posted ( Ok consumer ) ->
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
                consumers =
                    model.consumers
                        |> List.map ( toggle id )
            } ! []


toggle : String -> Consumer -> Consumer
toggle id consumer =
    if consumer.id == id then
        { consumer | selected = not consumer.selected }
    else
        consumer



-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (::)
            ( h1 [] [ text "Consumer" ] )
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView { action, editing, tableState, consumers } =
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Consumer" ]
            , Table.view config tableState consumers
            ]

        -- Adding | Editing
        _ ->
            [ lazy viewForm editing
            ]


viewForm : Maybe Consumer -> Html Msg
viewForm consumer =
    let
        editable : Consumer
        editable = case consumer of
            Nothing ->
                Consumer "" "" "" True "" "" "" "" "" "" "" "" 0.00 "" "" False

            Just consumer ->
                consumer
    in
        form [ onSubmit Post ] [
            Form.disabledTextRow "ID" editable.id ( SetFormValue (\v -> { editable | id = v }) )
            , Form.textRow "First Name" editable.firstname ( SetFormValue (\v -> { editable | firstname = v }) )
            , Form.textRow "Last Name" editable.lastname ( SetFormValue (\v -> { editable | lastname = v }) )
--            , Form.textRow "Active" editable.active ( SetFormValue (\v -> { editable | active = v }) )
            , Form.textRow "County Name" editable.countyName ( SetFormValue (\v -> { editable | countyName = v }) )
            , Form.textRow "County Code" editable.countyCode ( SetFormValue (\v -> { editable | countyCode = v }) )
            , Form.textRow "Funding Source" editable.fundingSource ( SetFormValue (\v -> { editable | fundingSource = v }) )
            , Form.textRow "Zip Code" editable.zip ( SetFormValue (\v -> { editable | zip = v }) )
            , Form.textRow "BSU" editable.bsu ( SetFormValue (\v -> { editable | bsu = v }) )
            , Form.textRow "Recipient ID" editable.recipientID ( SetFormValue (\v -> { editable | recipientID = v }) )
            , Form.textRow "DIA Code" editable.diaCode ( SetFormValue (\v -> { editable | diaCode = v }) )
            , Form.textRow "Consumer ID" editable.consumerID ( SetFormValue (\v -> { editable | consumerID = v }) )
            , Form.floatRow "Copay" ( toString editable.copay ) ( SetFormValue (\v -> { editable | copay = ( Result.withDefault 0.00 ( String.toFloat v ) ) }) )
            , Form.textRow "Discharge Date" editable.dischargeDate ( SetFormValue (\v -> { editable | dischargeDate = v }) )
            , Form.textRow "Other" editable.other ( SetFormValue (\v -> { editable | other = v }) )
            , Form.submitRow False Cancel
        ]


-- TABLE CONFIGURATION


config : Table.Config Consumer Msg
config =
    Table.customConfig
    { toId = .id
    , toMsg = SetTableState
    , columns =
        [ customColumn viewCheckbox
        , Table.stringColumn "ID" .id
        , Table.stringColumn "First Name" .firstname
        , Table.stringColumn "Last Name" .lastname
--        , Table.stringColumn "Active" .active
        , Table.stringColumn "County Name" .countyName
        , Table.stringColumn "County Code" .countyCode
        , Table.stringColumn "Funding Source" .fundingSource
        , Table.stringColumn "Zip Code" .zip
        , Table.stringColumn "BSU" .bsu
        , Table.stringColumn "Recipient ID" .recipientID
        , Table.stringColumn "DIA Code" .diaCode
        , Table.stringColumn "Consumer ID" .consumerID
        , Table.floatColumn "Copay" .copay
        , Table.stringColumn "Discharge Date" .dischargeDate
        , Table.stringColumn "Other" .other
        , customColumn viewButton
        , customColumn viewButton2
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : Consumer -> List ( Attribute Msg )
toRowAttrs { id, selected } =
    [ onClick ( ToggleSelected id )
    , style [ ( "background", if selected then "#CEFAF8" else "white" ) ]
    ]


customColumn : ( Consumer -> Table.HtmlDetails Msg ) -> Table.Column Consumer Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


-- TODO: Dry!
viewButton : Consumer -> Table.HtmlDetails Msg
viewButton consumer =
    Table.HtmlDetails []
        [ button [ onClick ( Edit consumer ) ] [ text "Edit" ]
        ]

viewButton2 : Consumer -> Table.HtmlDetails Msg
viewButton2 consumer =
    Table.HtmlDetails []
        [ button [ onClick ( Delete consumer ) ] [ text "Delete" ]
        ]

viewCheckbox : Consumer -> Table.HtmlDetails Msg
viewCheckbox { selected } =
    Table.HtmlDetails []
        [ input [ type_ "checkbox", checked selected ] []
        ]
------------

