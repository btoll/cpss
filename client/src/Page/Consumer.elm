module Page.Consumer exposing (Model, Msg, init, update, view)

import Css
import Data.Consumer exposing (Consumer)
import Date exposing (Date)
import Date.Extra.Config.Config_en_us exposing (config)
import Date.Extra.Format
import DateParser
import DateTimePicker
import DateTimePicker.Config exposing (Config, DatePickerConfig, TimePickerConfig, defaultDateTimePickerConfig)
import DateTimePicker.Css
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, text)
import Html.Attributes exposing (action, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Consumer
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Form as Form



-- MODEL


-- NOTE: Order matters here, the `consumers` field must be last b/c of partial application (see `init`)!
type alias Model =
    { tableState : Table.State
    , action : Action
    , editing : Maybe Consumer
    , disabled : Bool
    , date : Dict String Date -- The key is actually a DemoPicker
    , datePickerState : Dict String DateTimePicker.State -- The key is actually a DemoPicker
    , consumers : List Consumer
    }


type DemoPicker
    = AnalogDateTimePicker


type Action = None | Adding | Editing


init : String -> ( Model, Cmd Msg )
init url =
    ( Model ( Table.initialSort "ID" ) None Nothing True Dict.empty Dict.empty [] ) !
        [ Request.Consumer.get url |> Http.send Getted
        , DateTimePicker.initialCmd DatePickerChanged DateTimePicker.initialState
        ]


-- UPDATE


type Msg
    = Add
    | Cancel
    | DatePickerChanged DateTimePicker.State ( Maybe Date )
    | Delete Consumer
    | Deleted ( Result Http.Error () )
    | Edit Consumer
    | Getted ( Result Http.Error ( List Consumer ) )
    | Post
    | Posted ( Result Http.Error Consumer )
    | SetFormValue ( String -> Consumer ) String
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

        DatePickerChanged state value ->
            let
                editable : Consumer
                editable = case model.editing of
                    Nothing ->
                        Consumer "" "" "" True "" "" "" "" "" "" "" "" 0.00 "" "" False

                    Just consumer ->
                        consumer
            in
                { model
                    | date =
                        case value of
                            Nothing ->
                                Dict.remove ( toString AnalogDateTimePicker ) model.date

                            Just date ->
                                Dict.insert ( toString AnalogDateTimePicker ) date model.date
                    , datePickerState = Dict.insert ( toString AnalogDateTimePicker ) state model.datePickerState
                    , editing = Just ( { editable | dischargeDate = value |> toString } )
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


analogDateTimePickerConfig : Config ( DatePickerConfig TimePickerConfig ) Msg
analogDateTimePickerConfig =
    let
        defaultDateTimeConfig =
            defaultDateTimePickerConfig DatePickerChanged
    in
        { defaultDateTimeConfig
            | timePickerType = DateTimePicker.Config.Analog
            , allowYearNavigation = False
        }


view : Model -> Html Msg
view model =
    section []
        ( (::)
            ( h1 [] [ text "Consumer" ] )
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView ( { action, editing, tableState, consumers } as model ) =
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Consumer" ]
            , Table.view config tableState consumers
            ]

        -- Adding | Editing
        _ ->
--            [ lazy viewForm editing model
            [ viewForm model
            ]


viewForm : Model -> Html Msg
viewForm ( { disabled, editing, date, datePickerState } as model ) =
    let
        editable : Consumer
        editable = case editing of
            Nothing ->
                Consumer "" "" "" True "" "" "" "" "" "" "" "" 0.00 "" "" False

            Just consumer ->
                consumer

        { css } =
            Css.compile [ DateTimePicker.Css.css ]
    in
        form [ onSubmit Post ] [
            node "style" [] [ text css ]
            , Form.disabledTextRow "ID" editable.id ( SetFormValue (\v -> { editable | id = v }) )
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
            , Form.dateTimePickerRow "Discharge Date" "AnalogDateTimePicker" model analogDateTimePickerConfig
            , Form.textRow "Other" editable.other ( SetFormValue (\v -> { editable | other = v }) )
            , Form.submitRow disabled Cancel
        ]



-- TABLE CONFIGURATION


config : Table.Config Consumer Msg
config =
    Table.customConfig
    { toId = .id
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "ID" .id
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
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : Consumer -> List ( Attribute Msg )
toRowAttrs { id } =
    [ style [ ( "background", "white" ) ]
    ]


customColumn : ( Consumer -> Table.HtmlDetails Msg ) -> Table.Column Consumer Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( Consumer -> msg ) -> String -> Consumer -> Table.HtmlDetails msg
viewButton msg name consumer =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| consumer ] [ text name ]
        ]


