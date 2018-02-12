module Page.Consumer exposing (Model, Msg, init, update, view)

import Data.Consumer exposing (Consumer, new)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, text)
import Html.Attributes exposing (action, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Request.Consumer
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Date
import Validate.Consumer
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal



-- MODEL


type alias Model =
    { errors : List ( Validate.Consumer.Field, String )
    , tableState : Table.State
    , action : Action
    , editing : Maybe Consumer
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , date : Maybe Date
    , datePicker : DatePicker.DatePicker
    , consumers : List Consumer
    }


type Action = None | Adding | Editing


commonSettings : DatePicker.Settings
commonSettings =
    defaultSettings


settings : Maybe Date -> DatePicker.Settings
settings date =
    let
        isDisabled =
            case date of
                Nothing ->
                    commonSettings.isDisabled

                Just date ->
                    \d ->
                        Date.toTime d
                            > Date.toTime date
                            || (commonSettings.isDisabled d)
    in
        { commonSettings
            | placeholder = ""
            , isDisabled = isDisabled
        }



init : String -> ( Model, Cmd Msg )
init url =
    let
        ( datePicker, datePickerFx ) =
            DatePicker.init
    in
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , showModal = ( False, Nothing )
    , date = Nothing
    , datePicker = datePicker
    , consumers = []
    } ! [ Cmd.map DatePicker datePickerFx
    , Request.Consumer.get url |> Http.send FetchedConsumers
    ]


-- UPDATE


type Msg
    = Add
    | Cancel
    | DatePicker DatePicker.Msg
    | Delete Consumer
    | Deleted ( Result Http.Error () )
    | Edit Consumer
    | FetchedConsumers ( Result Http.Error ( List Consumer ) )
    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error Consumer )
    | Put
    | Putted ( Result Http.Error Consumer )
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
                , errors = []
            } ! []

        DatePicker subMsg ->
            let
                ( newDatePicker, datePickerFx, dateEvent ) =
                    DatePicker.update ( settings model.date ) subMsg model.datePicker

                ( newDate, newConsumer ) =
                    let
                        consumer = Maybe.withDefault new model.editing
                    in
                    case dateEvent of
                        Changed newDate ->
                            let
                                dateString =
                                    case dateEvent of
                                        Changed date ->
                                            case date of
                                                Nothing ->
                                                    ""

                                                Just d ->
                                                    d |> Util.Date.simple

                                        _ ->
                                            consumer.dischargeDate
                            in
                            ( newDate , { consumer | dischargeDate = dateString } )

                        _ ->
                            ( model.date, { consumer | dischargeDate = consumer.dischargeDate } )
            in
            { model
                | date = newDate
                , datePicker = newDatePicker
                , editing = Just newConsumer
            } ! [ Cmd.map DatePicker datePickerFx ]

        Delete consumer ->
            model ! []
--            { model |
--                showModal =
--                    ( True
--                    , specialist |> Modal.Delete |> Just
--                    )
--            } ! []
--            let
--                subCmd =
--                    Request.Consumer.delete url consumer
--                        |> Http.toTask
--                        |> Task.attempt Deleted
--            in
--                { model |
--                    action = None
--                    , editing = Nothing
--                } ! [ subCmd ]

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

        FetchedConsumers ( Ok consumers ) ->
            { model |
                consumers = consumers
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedConsumers ( Err err ) ->
            { model |
                consumers = []
                , tableState = Table.initialSort "ID"
            } ! []

        ModalMsg subMsg ->
            model ! []
--            let
--                ( bool, cmd ) =
--                    ( \invoice ->
--                        Request.Specialist.delete url invoice
--                            |> Http.toTask
--                            |> Task.attempt Deleted
--                    ) |> Modal.update subMsg
--            in
--            { model |
--                showModal = ( bool, Nothing )
--            } ! [ cmd ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just consumer ->
                            Validate.Consumer.errors consumer

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just consumer ->
                            ( None
                            , Request.Consumer.post url consumer
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

        Posted ( Ok consumer ) ->
            model ! []

        Posted ( Err err ) ->
            model ! []

        Put ->
--            let
--                errors =
--                    case model.editing of
--                        Nothing ->
--                            []
--
--                        Just consumer ->
--                            Validate.Consumer.errors consumer
--
--                ( action, subCmd ) = if errors |> List.isEmpty then
--                    case model.editing of
--                        Nothing ->
--                            ( None, Cmd.none )
--
--                        Just consumer ->
--                            ( None
--                            , Request.Consumer.put url consumer
--                                |> Http.toTask
--                                |> Task.attempt Putted
--                            )
--                    else
--                        ( Editing, Cmd.none )
--            in
--                { model |
--                    action = action
--                    , errors = errors
--                } ! [ subCmd ]
            model ! []

        Putted ( Ok consumer ) ->
            model ! []

        Putted ( Err err ) ->
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
        ( (++)
            [ h1 [] [ text "Consumer" ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView (
    { action
    , date
    , datePicker
    , disabled
    , editing
    , tableState
    , consumers
    } as model ) =
    let
        editable : Consumer
        editable = case editing of
            Nothing ->
                new

            Just consumer ->
                consumer
    in
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Consumer" ]
            , Table.view config tableState consumers
            , model.showModal
                |> Modal.view
                |> Html.map ModalMsg
            ]

        Adding ->
            [ form [ onSubmit Post ]
                ( (++)
                    ( ( editable, date, datePicker ) |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]

        Editing ->
            [ form [ onSubmit Put ]
                ( (++)
                    ( ( editable, date, datePicker ) |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]


formRows : ( Consumer, Maybe Date, DatePicker.DatePicker ) -> List ( Html Msg )
formRows ( editable, date, datePicker ) =
-- , Form.textRow "Active" editable.active ( SetFormValue (\v -> { editable | active = v }) )
    [ Form.text "ID"
        [ value editable.id
        , onInput ( SetFormValue ( \v -> { editable | id = v } ) )
        , disabled True
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
    , Form.text "County Name"
        [ value editable.countyName
        , onInput ( SetFormValue (\v -> { editable | countyName = v } ) )
        ]
        []
    , Form.text "County Code"
        [ value editable.countyCode
        , onInput ( SetFormValue (\v -> { editable | countyCode = v } ) )
        ]
        []
    , Form.text "Funding Source"
        [ value editable.fundingSource
        , onInput ( SetFormValue (\v -> { editable | fundingSource = v } ) )
        ]
        []
    , Form.text "Zip Code"
        [ value editable.zip
        , onInput ( SetFormValue (\v -> { editable | zip = v } ) )
        ]
        []
    , Form.text "BSU"
        [ value editable.bsu
        , onInput ( SetFormValue (\v -> { editable | bsu = v } ) )
        ]
        []
    , Form.text "Recipient ID"
        [ value editable.recipientID
        , onInput ( SetFormValue (\v -> { editable | recipientID = v } ) )
        ]
        []
    , Form.text "DIA Code"
        [ value editable.diaCode
        , onInput ( SetFormValue (\v -> { editable | diaCode = v } ) )
        ]
        []
    , Form.text "Consumer ID"
        [ value editable.consumerID
        , onInput ( SetFormValue (\v -> { editable | consumerID = v } ) )
        ]
        []
    , Form.float "Copay"
        [ value ( toString editable.copay )
        , onInput ( SetFormValue (\v -> { editable | copay = Form.toFloat v } ) )
        ]
        []
    , div []
        [ label [] [ text "Discharge Date" ]
        , DatePicker.view date ( settings date ) datePicker
            |> Html.map DatePicker
        ]
    , Form.text "Other"
        [ value editable.other
        , onInput ( SetFormValue (\v -> { editable | other = v } ) )
        ]
        []
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


