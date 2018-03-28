module Page.BillSheet exposing (Model, Msg, init, update, view)

import Data.Search exposing (Search, Query, ViewLists, fmtEquality)
import Data.BillSheet exposing (BillSheet, BillSheetWithPager, new)
import Data.Consumer exposing (Consumer)
import Data.County exposing (County)
import Data.Pager exposing (Pager)
import Data.User exposing (User)
import Data.Status exposing (Status)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, for, hidden, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Modal.Search
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
import Views.Page exposing (ViewAction(..))
import Views.Pager


-- MODEL

type alias Model =
    { errors : List ( Validate.BillSheet.Field, String )
    , tableState : Table.State
    , action : ViewAction
    , editing : Maybe BillSheet
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , date : Maybe Date
    , datePicker : DatePicker.DatePicker
    , viewLists : ViewLists
    , query : Maybe Query
    , pagerState : Pager
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
    , viewLists =
        { billsheets = []
        , consumers = []
        , counties = []
        , specialists = []
        , status = []
        }
    , query = Nothing
    , pagerState = Data.Pager.new
    } ! [ Cmd.map DatePicker datePickerFx
        , Request.Consumer.list url |> Http.send ( Consumers >> Fetch )
        , Request.County.list url |> Http.send ( Counties >> Fetch )
        , Request.Specialist.list url |> Http.send ( Specialists >> Fetch )
        , Request.Status.list url |> Http.send ( Statuses >> Fetch )
        , 0 |> Request.BillSheet.page url "" |> Http.send ( BillSheets >> Fetch )
        ]



-- UPDATE

type FetchedData
    = BillSheets ( Result Http.Error BillSheetWithPager )
    | Consumers ( Result Http.Error ( List Consumer ) )
    | Counties ( Result Http.Error ( List County ) )
    | Specialists ( Result Http.Error ( List User ) )
    | Statuses ( Result Http.Error ( List Status ) )


type Msg
    = Add
    | Cancel
    | ClearSearch
    | DatePicker DatePicker.Msg
    | Delete BillSheet
    | Deleted ( Result Http.Error Int )
    | Edit BillSheet
    | Fetch FetchedData
    | ModalMsg Modal.Msg
    | NewPage ( Maybe Int )
    | Post
    | Posted ( Result Http.Error BillSheet )
    | Put
    | Putted ( Result Http.Error BillSheet )
    | Query Query
    | Search ViewLists
    | Select Form.Selection BillSheet String
    | SetFormValue ( String -> BillSheet ) String
    | SetTableState Table.State


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update url msg model =
    let
        oldViewLists = model.viewLists
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

        ClearSearch ->
            { model |
                query = Nothing
            } ! [ 0
                    |> Request.BillSheet.page url ""
                    |> Http.send ( BillSheets >> Fetch )
                ]

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
                viewLists =
                    { oldViewLists |
                        billsheets =
                            oldViewLists.billsheets |> List.filter ( \m -> id /= m.id )
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

        Fetch result ->
            case result of
                BillSheets ( Ok billsheets ) ->
                    { model |
                        viewLists = { oldViewLists | billsheets = billsheets.billsheets }
                        , pagerState = billsheets.pager
                        , tableState = Table.initialSort "ID"
                    } ! []

                BillSheets ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | billsheets = [] }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Consumers ( Ok consumers ) ->
                    { model |
                        viewLists = { oldViewLists | consumers = consumers }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Consumers ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | consumers = [] }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Counties ( Ok counties ) ->
                    { model |
                        viewLists = { oldViewLists | counties = counties }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Counties ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | counties = [] }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Specialists ( Ok specialists ) ->
                    { model |
                        viewLists = { oldViewLists | specialists = specialists }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Specialists ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | specialists = [] }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Statuses ( Ok status ) ->
                    { model |
                        viewLists = { oldViewLists | status = status }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Statuses ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | status = [] }
                        , tableState = Table.initialSort "ID"
                    } ! []

        ModalMsg subMsg ->
            let
                ( showModal, whichModal, query, cmd ) =
                    case subMsg |> Modal.update model.query of
                        {- Delete Modal -}
                        ( False, Nothing ) ->
                            ( False, Nothing, Nothing, Cmd.none )

                        ( True, Nothing ) ->
                            ( False, Nothing, Nothing
                            , Maybe.withDefault new model.editing
                                |> Request.BillSheet.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
                            )

                        {- Search Modal -}
                        ( False, Just query ) ->
                            ( False
                            , Nothing
                            , query |> Just     -- We need to save the search query for paging!
                            , Http.send ( BillSheets >> Fetch )
                                << Request.BillSheet.query url
                                << String.dropRight 5   -- Remove the trailing " AND ".
                                << Dict.foldl fmtEquality ""
                                <| query
                            )

                        ( True, Just query ) ->
                            ( True
                            , model.viewLists |> Just
                                |> Modal.Search Data.Search.BillSheet model.query
                                |> Just
                            , query |> Just
                            , Cmd.none
                            )
            in
            { model |
                query = query
                , showModal = ( showModal, whichModal )
            } ! [ cmd ]

        NewPage page ->
            let
                fn : String -> String -> String -> String
                fn k v acc =
                    k ++ "=" ++ v ++ " AND "
                        |> (++) acc

                s =
                    model.query
                        |> Maybe.withDefault Dict.empty
                        |> Dict.foldl fn ""
                        |> String.dropRight 5   -- Remove the trailing " AND ".
            in
            model !
            [ page
                |> Maybe.withDefault -1
                |> Request.BillSheet.page url s
                |> Http.send ( BillSheets >> Fetch )
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
                            oldViewLists.billsheets

                        Just newBillSheet ->
                            oldViewLists.billsheets
                                |> (::) { newBillSheet | id = billsheet.id }
            in
            { model |
                viewLists = { oldViewLists | billsheets = billsheets }
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
                            oldViewLists.billsheets

                        Just newBillSheet ->
                            oldViewLists.billsheets
                                |> List.filter ( \m -> billsheet.id /= m.id )
                                |> (::)
                                    { newBillSheet | id = billsheet.id }
            in
                { model |
                    viewLists = { oldViewLists | billsheets = billsheets }
                    , editing = Nothing
                } ! []

        Putted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be updated!" model.errors
            } ! []

        Query query ->
            model ! []

        Search viewLists ->
            { model |
                showModal = ( True, viewLists |> Just |> Modal.Search Data.Search.BillSheet model.query |> Just )
            } ! []

        Select selectType billsheet selection ->
            let
                selectionToInt =
                    selection |> Form.toInt

                newModel a =
                    { model |
                        editing = a |> Just
                    }
            in
            case selectType of
                Form.ConsumerID ->
                    ( { billsheet | consumer = selectionToInt } |> newModel ) ! []

                Form.CountyID ->
                    ( { billsheet | county = selectionToInt } |> newModel ) ! []

                Form.SpecialistID ->
                    ( { billsheet | specialist = selectionToInt } |> newModel ) ! []

                Form.StatusID ->
                    ( { billsheet | status = selectionToInt } |> newModel ) ! []

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


view : Model -> Html Msg
view model =
    section []
        ( (++)
            [ h1 [] [ text "Bill Sheet" ]
            , Errors.view model.errors
            ]
            ( model |> drawView )
        )


drawView : Model -> List ( Html Msg )
drawView (
    { action
    , date
    , datePicker
    , disabled
    , editing
    , viewLists
    , query
    , tableState
    } as model ) =
    let
        editable : BillSheet
        editable = case editing of
            Nothing ->
                new

            Just billsheet ->
                billsheet

        ( showList, isDisabled ) =
            case viewLists.billsheets |> List.length of
                0 ->
                    ( div [] [], True )
                _ ->
                    ( viewLists.billsheets
                        |> Table.view ( model |> config ) tableState
                    , False )

        showPager =
            model.pagerState |> Views.Pager.view NewPage

        hideClearTextButton =
            case query of
                Nothing ->
                    True

                Just _ ->
                    False
    in
    case action of
        None ->
            [ button [ Add |> onClick ] [ text "Add Bill Sheet" ]
            , button [ isDisabled |> Html.Attributes.disabled, viewLists |> Search |> onClick ] [ text "Search" ]
            , button [ hideClearTextButton |> hidden, ClearSearch |> onClick ] [ text "Clear Search" ]
            , showPager
            , showList
            , showPager
            , model.showModal
                |> Modal.view query
                |> Html.map ModalMsg
            ]

        Adding ->
            [ form [ Post |> onSubmit ]
                ( (++)
                    ( ( editable, date, datePicker, viewLists ) |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]

        Editing ->
            [ form [ Put |> onSubmit ]
                ( (++)
                    ( ( editable, date, datePicker, viewLists ) |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]


formRows : ( BillSheet, Maybe Date, DatePicker.DatePicker, ViewLists ) -> List ( Html Msg )
formRows ( editable, date, datePicker, viewLists ) =
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
        [ editable.billedAmount |> toString |> value
        , onInput ( SetFormValue (\v -> { editable | billedAmount = Form.toFloat v } ) )
        ]
        []
    , Form.select "Consumer"
        [ id "consumerSelection"
        , editable |> Select Form.ConsumerID |> onInput
        ] (
            viewLists.consumers
                |> List.map ( \m -> ( m.id |> toString, m.lastname ++ ", " ++ m.firstname ) )
                |> (::) ( "-1", "-- Select a consumer --" )
                |> List.map ( editable.consumer |> toString |> Form.option )
        )
    , Form.select "Status"
        [ id "statusSelection"
        , editable |> Select Form.StatusID |> onInput
        ] (
            viewLists.status
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
        [ editable.service |> toString |> value
        , onInput ( SetFormValue (\v -> { editable | service = Form.toInt v } ) )
        ]
        []
    , Form.select "County"
        [ id "countySelection"
        , editable |> Select Form.CountyID |> onInput
        ] (
            viewLists.counties
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a county --" )
                |> List.map ( editable.county |> toString |> Form.option )
        )
    , Form.select "Specialist"
        [ id "specialistSelection"
        , editable |> Select Form.SpecialistID |> onInput
        ] (
            viewLists.specialists
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


config : Model -> Table.Config BillSheet Msg
config model =
    Table.customConfig
    { toId = .id >> toString
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Recipient ID" .recipientID
        , Table.stringColumn "Service Date" .serviceDate
        , Table.floatColumn "Billed Amount" .billedAmount
        , Table.stringColumn "Consumer" (
            .consumer
                >> ( \id ->
                    model.viewLists.consumers |> List.filter ( \m -> m.id |> (==) id )
                    )
                >> List.head
                >> Maybe.withDefault Data.Consumer.new
                >> ( \m -> m.firstname ++ " " ++  m.lastname )
        )
        , Table.stringColumn "Status" (
            .status
                >> ( \id ->
                    model.viewLists.status |> List.filter ( \m -> m.id |> (==) id )
                    )
                >> List.head
                >> Maybe.withDefault Data.Status.new
                >> .name
        )
        , Table.stringColumn "Confirmation" .confirmation
        , Table.intColumn "Service" .service
        , Table.stringColumn "County" (
            .county
                >> ( \id ->
                    model.viewLists.counties |> List.filter ( \m -> m.id |> (==) id )
                    )
                >> List.head
                >> Maybe.withDefault { id = -1, name = "" }
                >> .name
        )
        , Table.stringColumn "Specialist" (
            .specialist
                >> ( \id ->
                    model.viewLists.specialists |> List.filter ( \m -> m.id |> (==) id )
                    )
                >> List.head
                >> Maybe.withDefault Data.User.new
                >> ( \m -> m.firstname ++ " " ++  m.lastname )
        )
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


