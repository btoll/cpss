module Page.BillSheet.BillSheet exposing (Model, Msg, formRows, init, tableColumns, update)


import Data.BillSheet exposing (BillSheet, new)
import Data.Consumer exposing (Consumer)
import Data.Search exposing (ViewLists)
import Data.Status exposing (Status)
import Data.User exposing (User)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, for, hidden, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Date
import Validate.BillSheet
import Views.Errors as Errors
import Views.Form as Form



-- MODEL


type alias Model =
    { tableState : Table.State
    , editing : Maybe BillSheet
    , disabled : Bool
    , date : Maybe Date
    , datePicker : DatePicker.DatePicker
    }


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



init : Model
init =
    let
        ( datePicker, _ ) =
            DatePicker.init
    in
    { tableState = Table.initialSort "ID"
    , editing = Nothing
    , disabled = True
    , date = Nothing
    , datePicker = datePicker
    }


type Msg
    = DatePicker DatePicker.Msg
    | Select Form.Selection BillSheet String
    | SetFormValue ( String -> BillSheet ) String
    | SetTableState Table.State



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DatePicker subMsg ->
            let
                ( newDatePicker, datePickerFx, dateEvent ) =
                    DatePicker.update ( settings model.date ) subMsg model.datePicker

                ( newDate, newBillSheet ) =
                    let
                        billsheet = Maybe.withDefault new model.editing
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
                                            billsheet.serviceDate
                            in
                            ( newDate , { billsheet | serviceDate = dateString } )

                        _ ->
                            ( model.date, { billsheet | serviceDate = billsheet.serviceDate } )
            in
            { model
                | date = newDate
                , datePicker = newDatePicker
                , editing = Just newBillSheet
            } ! [ Cmd.map DatePicker datePickerFx ]

        Select selectType consumer selection ->
            let
                selectionToInt =
                    selection |> Form.toInt

                newModel a =
                    { model |
                        editing = a |> Just
                        , disabled = False
                    }
            in
            case selectType of
                Form.ConsumerID ->
                    ( { consumer | consumer = selectionToInt } |> newModel ) ! []

                Form.CountyID ->
                    ( { consumer | county = selectionToInt } |> newModel ) ! []

                Form.ServiceCodeID ->
                    ( { consumer | serviceCode = selectionToInt } |> newModel ) ! []

                Form.SpecialistID ->
                    ( { consumer | specialist = selectionToInt } |> newModel ) ! []

                Form.StatusID ->
                    ( { consumer | status = selectionToInt } |> newModel ) ! []

                _ ->
                    model ! []

        SetFormValue setFormValue s ->
            { model |
                editing = Just ( setFormValue s )
                , disabled = False
            } ! []

        SetTableState newState ->
            { model | tableState = newState
            } ! []



-- VIEW


formRows : ViewLists -> Model -> List ( Html Msg )
formRows viewLists model =
    let
        editable : BillSheet
        editable = case model.editing of
            Nothing ->
                new

            Just billsheet ->
                billsheet

        focusedDate : Maybe Date
        focusedDate =
            case (/=) editable.serviceDate "" of
                True ->
                    editable.serviceDate |> Util.Date.unsafeFromString |> Just
                False ->
                    model.date

        consumers = Maybe.withDefault [] viewLists.consumers
        counties = Maybe.withDefault [] viewLists.counties
        serviceCodes = Maybe.withDefault [] viewLists.serviceCodes
        specialists = Maybe.withDefault [] viewLists.specialists
        status = Maybe.withDefault [] viewLists.status
    in
    [ Form.text "Recipient ID"
        [ value editable.recipientID
        , onInput ( SetFormValue ( \v -> { editable | recipientID = v } ) )
        , autofocus True
        ]
        []
    , Form.select "Service Code"
        [ id "serviceCodeSelection"
        , editable |> Select Form.ServiceCodeID |> onInput
        ] (
            serviceCodes
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a service code --" )
                |> List.map ( editable.serviceCode |> toString |> Form.option )
        )
    , div []
        [ label [] [ text "Service Date" ]
        , DatePicker.view focusedDate ( model.date |> settings ) model.datePicker
            |> Html.map DatePicker
        ]
    , Form.float "Billed Amount"
        [ editable.billedAmount |> toString |> value
        , onInput ( SetFormValue (\v -> { editable | billedAmount = Form.toFloat v } ) )
        ]
        []
    , Form.float "Units"
        [ editable.units |> toString |> value
        , onInput ( SetFormValue (\v -> { editable | units = Form.toFloat v } ) )
        ]
        []
    , Form.select "Consumer"
        [ id "consumerSelection"
        , editable |> Select Form.ConsumerID |> onInput
        ] (
            consumers
                |> List.map ( \m -> ( m.id |> toString, m.lastname ++ ", " ++ m.firstname ) )
                |> (::) ( "-1", "-- Select a consumer --" )
                |> List.map ( editable.consumer |> toString |> Form.option )
        )
    , Form.select "Status"
        [ id "statusSelection"
        , editable |> Select Form.StatusID |> onInput
        ] (
            status
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a status --" )
                |> List.map ( editable.status |> toString |> Form.option )
        )
    , Form.text "Confirmation"
        [ value editable.confirmation
        , onInput ( SetFormValue (\v -> { editable | confirmation = v } ) )
        ]
        []
    , Form.select "County"
        [ id "countySelection"
        , editable |> Select Form.CountyID |> onInput
        ] (
            counties
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a county --" )
                |> List.map ( editable.county |> toString |> Form.option )
        )
    , Form.select "Specialist"
        [ id "specialistSelection"
        , editable |> Select Form.SpecialistID |> onInput
        ] (
            specialists
                |> List.map ( \m -> ( m.id |> toString, m.lastname ++ ", " ++ m.firstname ) )
                |> (::) ( "-1", "-- Select a specialist --" )
                |> List.map ( editable.specialist |> toString |> Form.option )
        )
    , Form.text "Record Number"
        [ value editable.recordNumber
        , onInput ( SetFormValue (\v -> { editable | recordNumber = v } ) )
        ]
        []
    ]



-- TABLE CONFIGURATION


tableColumns customColumn viewButton editMsg deleteMsg viewLists =
    let
        consumers = Maybe.withDefault [] viewLists.consumers
        counties = Maybe.withDefault [] viewLists.counties
        specialists = Maybe.withDefault [] viewLists.specialists
        status = Maybe.withDefault [] viewLists.status
    in
    [ Table.stringColumn "Recipient ID" .recipientID
    , Table.stringColumn "Service Date" .serviceDate
    , Table.floatColumn "Billed Amount" .billedAmount
    , Table.floatColumn "Units" .units
    , Table.stringColumn "Consumer" (
        .consumer
            >> ( \id ->
                consumers |> List.filter ( \m -> m.id |> (==) id )
                )
            >> List.head
            >> Maybe.withDefault Data.Consumer.new
            >> ( \m -> m.firstname ++ " " ++  m.lastname )
    )
    , Table.stringColumn "Status" (
        .status
            >> ( \id ->
                status |> List.filter ( \m -> m.id |> (==) id )
                )
            >> List.head
            >> Maybe.withDefault Data.Status.new
            >> .name
    )
    , Table.stringColumn "Confirmation" .confirmation
    , Table.intColumn "Service Code" .serviceCode
    , Table.stringColumn "County" (
        .county
            >> ( \id ->
                counties |> List.filter ( \m -> m.id |> (==) id )
                )
            >> List.head
            >> Maybe.withDefault { id = -1, name = "" }
            >> .name
    )
    , Table.stringColumn "Specialist" (
        .specialist
            >> ( \id ->
                specialists |> List.filter ( \m -> m.id |> (==) id )
                )
            >> List.head
            >> Maybe.withDefault Data.User.new
            >> ( \m -> m.firstname ++ " " ++  m.lastname )
    )
    , Table.stringColumn "Record Number" .recordNumber
    , customColumn ( viewButton editMsg "Edit" )
    , customColumn ( viewButton deleteMsg "Delete" )
    ]


