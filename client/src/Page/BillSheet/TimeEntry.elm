module Page.BillSheet.TimeEntry exposing (Model, Msg, formRows, init, tableColumns, update)



import Data.BillSheet exposing (BillSheet, new)
import Data.Consumer exposing (Consumer)
import Data.Search exposing (ViewLists)
import Data.ServiceCode exposing (ServiceCode)
import Data.Status exposing (Status)
import Data.User exposing (User)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, for, hidden, id, multiple, style, type_, value)
import Html.Events exposing (onCheck, onClick, onInput, onSubmit)
import Http
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Date
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


-- Disable all dates before current date (taken from localStorage session).
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
                            < Date.toTime date
                            || ( d |> commonSettings.isDisabled )
    in
        { commonSettings
            | placeholder = ""
            , isDisabled = isDisabled
            , dateFormatter = Util.Date.simple
        }



init : String -> ( Model, Cmd Msg )
init dateString =
    let
        ( datePicker, datePickerFx ) =
            DatePicker.init

        newBillSheet = Data.BillSheet.new
    in
    (
        { tableState = Table.initialSort "ID"
        , editing = { new | serviceDate = dateString } |> Just
        , disabled = True
        , date = dateString |> Util.Date.unsafeFromString |> Just
        , datePicker = datePicker
        }
        , Cmd.map DatePicker datePickerFx
    )



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

                newDate =
                    case dateEvent of
                        Changed newDate ->
                            newDate

                        _ ->
                            model.date

                billsheet = Maybe.withDefault new model.editing
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
            { model
                | date = newDate
                , datePicker = newDatePicker
                , editing = Just { billsheet | serviceDate = dateString }
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
        serviceCodes = Maybe.withDefault [] viewLists.serviceCodes
    in
    [ Form.select "Consumer"
        [ id "consumerSelection"
        , editable |> Select Form.ConsumerID |> onInput
        , autofocus True
        ] (
            consumers
                |> List.map ( \m -> ( m.id |> toString, ( m.lastname ++ ", " ++ m.firstname ) ) )
                |> (::) ( "-1", "-- Select a Consumer --" )
                |> List.map ( editable.consumer |> toString |> Form.option )
        )
    , div []
        [ label [] [ text "Service Date" ]
        , DatePicker.view focusedDate ( model.date |> settings ) model.datePicker
            |> Html.map DatePicker
        ]
    , Form.select "Service Code"
        [ id "serviceCodeSelection"
        , editable |> Select Form.ServiceCodeID |> onInput
        ] (
            serviceCodes
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a Service code --" )
                |> List.map ( editable.serviceCode |> toString |> Form.option )
        )
    , Form.float "Hours"
        -- Recall that everything is now in units, so conversion to hours is done here!
        [ 4.0 |> (/) editable.units |> toString |> value
        , onInput ( SetFormValue (\v -> { editable | units = 4.0 |> (*) ( v |> Form.toFloat ) } ) )
        ,  "0.25" |> Html.Attributes.step
        ]
        []
    , Form.textarea "Description"
        [ value editable.description
        , onInput ( SetFormValue ( \v -> { editable | description = v } ) )
        ]
        []
    ]



-- TABLE CONFIGURATION


tableColumns customColumn viewButton editMsg deleteMsg viewLists =
    let
        consumers = Maybe.withDefault [] viewLists.consumers
        serviceCodes = Maybe.withDefault [] viewLists.serviceCodes
    in
    [ Table.stringColumn "Consumer" (
        .consumer
            >> ( \id ->
                consumers |> List.filter ( \m -> m.id |> (==) id )
                )
            >> List.head
            >> Maybe.withDefault Data.Consumer.new
            >> ( \m -> m.lastname ++ ", " ++  m.firstname )
    )
    , Table.stringColumn "Service Date" .serviceDate
    , Table.stringColumn "ServiceCode" (
        .serviceCode
            >> ( \id ->
                serviceCodes |> List.filter ( \m -> m.id |> (==) id )
                )
            >> List.head
            >> Maybe.withDefault Data.ServiceCode.new
            >> .name
    )
    , Table.floatColumn "Hours" ( \m ->
        -- Recall that everything is now in units, so conversion to hours is done here!
        4.0 |> (/) m.units
    )
    , Table.stringColumn "Description" .description
    , customColumn "" ( viewButton editMsg "Edit" )
    , customColumn "" ( viewButton deleteMsg "Delete" )
    ]


