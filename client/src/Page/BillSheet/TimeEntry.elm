module Page.BillSheet.TimeEntry exposing (Model, Msg, formRows, init, tableColumns, update)


import Data.BillSheet exposing (BillSheet, new)
import Data.Consumer exposing (Consumer)
import Data.Search exposing (ViewLists)
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
                            || ( commonSettings.isDisabled d )
    in
        { commonSettings
            | placeholder = ""
            , isDisabled = isDisabled
        }



init : User -> Model
init user =
    let
        ( datePicker, datePickerFx ) =
            DatePicker.init

        newBillSheet = Data.BillSheet.new
    in
    { tableState = Table.initialSort "ID"
--    , editing = { newBillSheet | specialist = user.id } |> Just
    , editing = Nothing
    , disabled = True
    , date = Nothing
    , datePicker = datePicker
    }



type Msg
    = DatePicker DatePicker.Msg
    | Select Form.Selection BillSheet String
    | SetCheckboxValue ( Bool -> BillSheet ) Bool
    | SetFormValue ( String -> BillSheet ) String
    | SetTableState Table.State



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        m = (Debug.log "model.editing" model.editing)
    in
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

        SetCheckboxValue setBoolValue b ->
            { model |
                editing = setBoolValue b |> Just
                , disabled = False
            } ! []

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
    in
    [ Form.select "Consumer"
        [ id "consumerSelection"
        , editable |> Select Form.ConsumerID |> onInput
        , autofocus True
        ] (
            consumers
                |> List.map ( \m -> ( m.id |> toString, ( m.lastname ++ ", " ++ m.firstname ) ) )
                |> (::) ( "-1", "-- Select a consumer --" )
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
--        , True |> multiple
        ] (
            serviceCodes
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a service code --" )
                |> List.map ( editable.serviceCode |> toString |> Form.option )
        )
    , Form.checkbox "Hold"
        [ checked editable.hold
        , onCheck ( SetCheckboxValue ( \v -> { editable | hold = v } ) )
        ]
        []
    , Form.float "Hours"
        [ editable.hours |> toString |> value
        , onInput ( SetFormValue (\v -> { editable | hours = Form.toFloat v } ) )
        ,  "0.25" |> Html.Attributes.step
        ]
        []
    , Form.text "Description"
        [ value editable.description
        , onInput ( SetFormValue ( \v -> { editable | description = v } ) )
        ]
        []
    , Form.select "County"
        [ id "countySelection"
        , editable |> Select Form.CountyID |> onInput
        ] (
            counties
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a county--" )
                |> List.map ( editable.county |> toString |> Form.option )
        )
    , Form.text "Contract Type"
        [ value editable.contractType
        , True |> Html.Attributes.disabled
        ]
        []
    , Form.text "Billed Code"
        [ value editable.billedCode
        , onInput ( SetFormValue ( \v -> { editable | billedCode = v } ) )
        ]
        []
    ]



-- TABLE CONFIGURATION


tableColumns customColumn viewButton viewCheckbox editMsg deleteMsg viewLists =
    let
        consumers = Maybe.withDefault [] viewLists.consumers
        counties = Maybe.withDefault [] viewLists.counties
    in
    [ Table.stringColumn "Consumer" (
        .consumer
            >> ( \id ->
                consumers |> List.filter ( \m -> m.id |> (==) id )
                )
            >> List.head
            >> Maybe.withDefault Data.Consumer.new
            >> ( \m -> m.firstname ++ " " ++  m.lastname )
    )
    , Table.stringColumn "Service Date" .serviceDate
    , Table.intColumn "Service Code" .serviceCode
    , customColumn "Hold" viewCheckbox
    , Table.floatColumn "Hours" .hours
    , Table.stringColumn "Description" .description
    , Table.stringColumn "County" (
        .county
            >> ( \id ->
                counties |> List.filter ( \m -> m.id |> (==) id )
                )
            >> List.head
            >> Maybe.withDefault { id = -1, name = "" }
            >> .name
    )
    , Table.stringColumn "Contract Type" .contractType
    , Table.stringColumn "Billed Code" .billedCode
    , customColumn "" ( viewButton editMsg "Edit" )
    , customColumn "" ( viewButton deleteMsg "Delete" )
    ]

