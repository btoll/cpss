module Page.BillSheet exposing (Model, Msg, init, update, view)

import Data.BillSheet exposing (BillSheet, BillSheetWithPager, new)
import Data.Consumer exposing (Consumer)
import Data.County exposing (County)
import Data.Pager exposing (Pager)
import Data.User exposing (User)
import Data.Status exposing (Status)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Request.BillSheet
import Request.Consumer
import Request.County
import Request.Specialist
import Request.Status
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Date
import Validate.BillSheet
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal
import Views.Pager


-- MODEL

type alias PageLists =
    { billsheets : List BillSheet
    , consumers : List Consumer
    , counties : List County
    , specialists : List User
    , status : List Status
    }

type alias Model =
    { errors : List ( Validate.BillSheet.Field, String )
    , tableState : Table.State
    , action : Action
    , editing : Maybe BillSheet
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , date : Maybe Date
    , datePicker : DatePicker.DatePicker
    , pageLists : PageLists
    , pager : Pager
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
    , pageLists =
        { billsheets = []
        , consumers = []
        , counties = []
        , specialists = []
        , status = []
        }
    , pager = Data.Pager.new
    } ! [ Cmd.map DatePicker datePickerFx
        , Request.Consumer.list url |> Http.send FetchedConsumers
        , Request.County.list url |> Http.send FetchedCounties
        , Request.Specialist.list url |> Http.send FetchedSpecialists
        , Request.Status.list url |> Http.send FetchedStatus
        , 0 |> Request.BillSheet.page url |> Http.send FetchedBillSheets
        ]



-- UPDATE


type Msg
    = Add
    | Cancel
    | DatePicker DatePicker.Msg
    | Delete BillSheet
    | Deleted ( Result Http.Error Int )
    | Edit BillSheet
    | FetchedBillSheets ( Result Http.Error BillSheetWithPager )
    | FetchedConsumers ( Result Http.Error ( List Consumer ) )
    | FetchedCounties ( Result Http.Error ( List County ) )
    | FetchedSpecialists ( Result Http.Error ( List User ) )
    | FetchedStatus ( Result Http.Error ( List Status ) )
    | ModalMsg Modal.Msg
    | PagerMsg Views.Pager.Msg
    | Post
    | Posted ( Result Http.Error BillSheet )
    | Put
    | Putted ( Result Http.Error BillSheet )
    | SelectConsumer BillSheet String
    | SelectCounty BillSheet String
    | SelectSpecialist BillSheet String
    | SelectStatus BillSheet String
    | SetFormValue ( String -> BillSheet ) String
    | SetTableState Table.State
    | Submit


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update url msg model =
    let
        oldPageLists = model.pageLists
    in
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

        Delete billsheet ->
            { model |
                editing = Just billsheet
                , showModal = ( True , Modal.Delete |> Just )
            } ! []

        Deleted ( Ok id ) ->
            { model |
                pageLists =
                    { oldPageLists |
                        billsheets =
                            oldPageLists.billsheets |> List.filter ( \m -> id /= m.id )
                    }
            } ! []

        Deleted ( Err err ) ->
            { model |
                action = None
--                , errors = (::) "There was a problem, the record could not be deleted!" model.errors
            } ! []

        Edit billsheet ->
            { model |
                action = Editing
                , editing = Just billsheet
            } ! []

        FetchedBillSheets ( Ok billsheets ) ->
            { model |
                pageLists = { oldPageLists | billsheets = billsheets.billsheets }
                , pager = billsheets.pager
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedBillSheets ( Err err ) ->
            { model |
                pageLists = { oldPageLists | billsheets = [] }
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedConsumers ( Ok consumers ) ->
            { model |
                pageLists = { oldPageLists | consumers = consumers }
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedConsumers ( Err err ) ->
            { model |
                pageLists = { oldPageLists | consumers = [] }
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedCounties ( Ok counties ) ->
            { model |
                pageLists = { oldPageLists | counties = counties }
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedCounties ( Err err ) ->
            { model |
                pageLists = { oldPageLists | counties = [] }
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedSpecialists ( Ok specialists ) ->
            { model |
                pageLists = { oldPageLists | specialists = specialists }
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedSpecialists ( Err err ) ->
            { model |
                pageLists = { oldPageLists | specialists = [] }
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedStatus ( Ok status ) ->
            { model |
                pageLists = { oldPageLists | status = status }
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedStatus ( Err err ) ->
            { model |
                pageLists = { oldPageLists | status = [] }
                , tableState = Table.initialSort "ID"
            } ! []

        ModalMsg subMsg ->
            let
                cmd =
                    case ( subMsg |> Modal.update ) of
                        False ->
                            Cmd.none

                        True ->
                            Maybe.withDefault new model.editing
                                |> Request.BillSheet.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
            in
            { model |
                showModal = ( False, Nothing )
            } ! [ cmd ]

        PagerMsg subMsg ->
            model !
            [ subMsg
                |>Views.Pager.update ( model.pager.currentPage, model.pager.totalPages )
                |> Request.BillSheet.page url
                |> Http.send FetchedBillSheets
            ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just billsheet ->
                            Validate.BillSheet.errors billsheet

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just billsheet ->
                            ( None
                            , Request.BillSheet.post url billsheet
                                |> Http.toTask
                                |> Task.attempt Posted
                            )
                    else
                        ( Adding, Cmd.none )
            in
                { model |
                    action = action
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok billsheet ) ->
            let
                billsheets =
                    case model.editing of
                        Nothing ->
                            oldPageLists.billsheets

                        Just newBillSheet ->
                            oldPageLists.billsheets
                                |> (::) { newBillSheet | id = billsheet.id }
            in
            { model |
                pageLists = { oldPageLists | billsheets = billsheets }
            } ! []

        Posted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be saved!" model.errors
            } ! []

        Put ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just billsheet ->
                            Validate.BillSheet.errors billsheet

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just billsheet ->
                            ( None
                            , Request.BillSheet.put url billsheet
                                |> Http.toTask
                                |> Task.attempt Putted
                            )
                    else
                        ( Editing, Cmd.none )
            in
                { model |
                    action = action
                    , errors = errors
                } ! [ subCmd ]

        Putted ( Ok billsheet ) ->
            let
                billsheets =
                    case model.editing of
                        Nothing ->
                            oldPageLists.billsheets

                        Just newBillSheet ->
                            oldPageLists.billsheets
                                |> List.filter ( \m -> billsheet.id /= m.id )
                                |> (::)
                                    { newBillSheet | id = billsheet.id }
            in
                { model |
                    pageLists = { oldPageLists | billsheets = billsheets }
                    , editing = Nothing
                } ! []

        Putted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be updated!" model.errors
            } ! []

        SelectConsumer billsheet consumer ->
            { model |
                editing = { billsheet | consumer = consumer |> Form.toInt } |> Just
            } ! []

        SelectCounty billsheet countyID ->
            { model |
                editing = { billsheet | county = countyID |> Form.toInt } |> Just
            } ! []

        SelectSpecialist billsheet specialistID ->
            { model |
                editing = { billsheet | specialist = specialistID |> Form.toInt } |> Just
            } ! []

        SelectStatus billsheet statusID ->
            { model |
                editing = { billsheet | status = statusID |> Form.toInt } |> Just
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



-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (++)
            [ h1 [] [ text "Bill Sheet" ]
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
    , pageLists
    , tableState
    } as model ) =
    let
        editable : BillSheet
        editable = case editing of
            Nothing ->
                new

            Just billsheet ->
                billsheet

        showList =
            case pageLists.billsheets |> List.length of
                0 ->
                    div [] []
                _ ->
                    Table.view config tableState pageLists.billsheets
    in
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Bill Sheet" ]
            , showList
            , model.showModal
                |> Modal.view
                |> Html.map ModalMsg
            ]

        Adding ->
            [ form [ onSubmit Post ]
                ( (++)
                    ( ( editable, date, datePicker, pageLists ) |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]

        Editing ->
            [ form [ onSubmit Put ]
                ( (++)
                    ( ( editable, date, datePicker, pageLists ) |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]


formRows : ( BillSheet, Maybe Date, DatePicker.DatePicker, PageLists ) -> List ( Html Msg )
formRows ( editable, date, datePicker, pageLists ) =
    [ Form.text "Recipient ID"
        [ value editable.recipientID
        , onInput ( SetFormValue ( \v -> { editable | recipientID = v } ) )
        , autofocus True
        ]
        []
    , div []
        [ label [] [ text "Service Date" ]
        , DatePicker.view date ( settings date ) datePicker
            |> Html.map DatePicker
        ]
    , Form.float "Billed Amount"
        [ value ( toString editable.billedAmount )
        , onInput ( SetFormValue (\v -> { editable | billedAmount = Form.toFloat v } ) )
        ]
        []
    , Form.select "Consumer"
        [ id "consumerSelection"
        , editable |> SelectConsumer |> onInput
        ] (
            pageLists.consumers
                |> List.map ( \m -> ( m.id |> toString, m.lastname ++ ", " ++ m.firstname ) )
                |> (::) ( "-1", "-- Select a consumer --" )
                |> List.map ( editable.consumer |> toString |> Form.option )
        )
    , Form.select "Status"
        [ id "statusSelection"
        , editable |> SelectStatus |> onInput
        ] (
            pageLists.status
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a status --" )
                |> List.map ( editable.status |> toString |> Form.option )
        )
    , Form.text "Confirmation"
        [ value editable.confirmation
        , onInput ( SetFormValue (\v -> { editable | confirmation = v } ) )
        ]
        []
    , Form.text "Service"
        [ value ( toString editable.service )
        , onInput ( SetFormValue (\v -> { editable | service = Form.toInt v } ) )
        ]
        []
    , Form.select "County"
        [ id "countySelection"
        , editable |> SelectCounty |> onInput
        ] (
            pageLists.counties
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a county --" )
                |> List.map ( editable.county |> toString |> Form.option )
        )
    , Form.select "Specialist"
        [ id "specialistSelection"
        , editable |> SelectSpecialist |> onInput
        ] (
            pageLists.specialists
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


config : Table.Config BillSheet Msg
config =
    Table.customConfig
    { toId = .id >> toString
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Recipient ID" .recipientID
        , Table.stringColumn "Service Date" .serviceDate
        , Table.floatColumn "Billed Amount" .billedAmount
        , Table.intColumn "Consumer" .consumer
        , Table.intColumn "Status" .status
        , Table.stringColumn "Confirmation" .confirmation
        , Table.intColumn "Service" .service
        , Table.intColumn "County" .county
        , Table.intColumn "Specialist" .specialist
        , Table.stringColumn "Record Number" .recordNumber
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        ]
    , customizations = defaultCustomizations
    }


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


