module Page.TimeEntry exposing (Model, Msg, init, update, view)

import Data.Search exposing (Query)
import Data.Consumer exposing (Consumer)
import Data.Pager exposing (Pager)
import Data.Session exposing (Session)
import Data.ServiceCode exposing (ServiceCode)
import Data.TimeEntry as TimeEntry exposing (TimeEntry, TimeEntryWithPager, new)
import Data.User exposing (User)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, step, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Request.Consumer
import Request.ServiceCode
import Request.TimeEntry
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Date
import Validate.TimeEntry
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal
import Views.Pager



-- MODEL


type alias PageLists =
    { timeEntryWithPager : TimeEntryWithPager
    , serviceCodes : List ServiceCode
    , consumers : List Consumer
    }


type alias Model =
    { errors : List ( Validate.TimeEntry.Field, String )
    , tableState : Table.State
    , action : Action
    , editing : Maybe TimeEntry
    , disabled : Bool
    , changingPassword : String         -- Use for both storing current password and new password when changing password!
    , showModal : ( Bool, Maybe Modal.Modal )
    , date : Maybe Date
    , datePicker : DatePicker.DatePicker
    , pageLists : PageLists
    , query : Maybe Query
    , user : User
    }


type Action
    = None
    | Adding
    | Editing


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



init : String -> Session -> ( Model, Cmd Msg )
init url session =
    let
        user : User
        user =
            case session.user of
                Nothing ->
                    Data.User.new

                Just user ->
                    user

        ( datePicker, datePickerFx ) =
            DatePicker.init
    in
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , changingPassword = ""         -- Use for both storing current password and new password when changing password!
    , showModal = ( False, Nothing )
    , date = Nothing
    , datePicker = datePicker
    , pageLists =
        { timeEntryWithPager =
            { timeEntries = [ new ]
            , pager = Data.Pager.new
            }
        , serviceCodes = []
        , consumers = []
        }
    , query = Nothing
    , user = user
    } ! [ Cmd.map DatePicker datePickerFx
        , Request.Consumer.list url |> Http.send ( \result -> result |> Consumers |> Fetch )
        , Request.ServiceCode.list url |> Http.send ( \result -> result |> ServiceCodes |> Fetch )
        , 0 |> Request.TimeEntry.page url |> Http.send ( \result -> result |> TimeEntries |> Fetch )
        ]



-- UPDATE

type FetchedData
    = Consumers ( Result Http.Error ( List Consumer ) )
    | ServiceCodes ( Result Http.Error ( List ServiceCode ) )
    | TimeEntries ( Result Http.Error TimeEntryWithPager )


type Msg
    = Add
    | Cancel
    | DatePicker DatePicker.Msg
    | Delete TimeEntry
    | Deleted ( Result Http.Error Int )
    | Edit TimeEntry
    | Fetch FetchedData
    | ModalMsg Modal.Msg
    | NewPage ( Maybe Int )
    | Post
    | Posted ( Result Http.Error TimeEntry )
    | Put
    | Putted ( Result Http.Error TimeEntry )
    | Search
    | Select Form.Selection TimeEntry String
    | SetFormValue ( String -> TimeEntry ) String
    | SetTableState Table.State


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
                , disabled = True
                , editing = Nothing
                , errors = []
            } ! []

        DatePicker subMsg ->
            let
                ( newDatePicker, datePickerFx, dateEvent ) =
                    DatePicker.update ( settings model.date ) subMsg model.datePicker

                ( newDate, newTimeEntry ) =
                    let
                        timeEntry = Maybe.withDefault new model.editing
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
                                            timeEntry.serviceDate
                            in
                            ( newDate , { timeEntry | serviceDate = dateString } )

                        _ ->
                            ( model.date, { timeEntry | serviceDate = timeEntry.serviceDate } )
            in
            { model
                | date = newDate
                , datePicker = newDatePicker
                , editing = Just newTimeEntry
            } ! [ Cmd.map DatePicker datePickerFx ]

        Delete timeEntry ->
            { model |
                editing = Just timeEntry
                , showModal = ( True , Modal.Delete |> Just )
            } ! []

        Deleted ( Ok timeEntryID ) ->
            let
                oldPageLists = model.pageLists
                oldTimeEntryWithPager = oldPageLists.timeEntryWithPager
            in
                { model |
                    pageLists =
                        { oldPageLists |
                            timeEntryWithPager =
                                { oldTimeEntryWithPager |
                                    timeEntries =
                                        oldTimeEntryWithPager.timeEntries
                                            |> List.filter ( \m -> timeEntryID /= m.id )
                                }
                        }
                } ! []

        Deleted ( Err err ) ->
            { model |
                action = None
--                , errors = (::) "There was a problem, the record could not be deleted!" model.errors
            } ! []

        Edit timeEntry ->
            { model |
                action = Editing
                , editing = Just timeEntry
            } ! []

        Fetch result ->
            case result of
                Consumers ( Ok consumers ) ->
                    { model |
                        pageLists = { oldPageLists | consumers = consumers }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Consumers ( Err err ) ->
                    { model |
                        pageLists = { oldPageLists | consumers = [] }
                        , tableState = Table.initialSort "ID"
                    } ! []

                ServiceCodes ( Ok serviceCodes ) ->
                    { model |
                        pageLists = { oldPageLists | serviceCodes = serviceCodes }
                        , tableState = Table.initialSort "ID"
                    } ! []

                ServiceCodes ( Err err ) ->
                    { model |
                        pageLists = { oldPageLists | serviceCodes = [] }
                        , tableState = Table.initialSort "ID"
                    } ! []

                TimeEntries ( Ok timeEntries ) ->
                    let
                        oldTimeEntryWithPager = oldPageLists.timeEntryWithPager
                        newTimeEntries = { oldTimeEntryWithPager | timeEntries = timeEntries.timeEntries }
                    in
                    { model |
                        pageLists = { oldPageLists | timeEntryWithPager = newTimeEntries }
        --                , pager = timeEntries.pager
                        , tableState = Table.initialSort "ID"
                    } ! []

                TimeEntries ( Err err ) ->
                    let
                        oldTimeEntryWithPager = oldPageLists.timeEntryWithPager
                    in
                    { model |
                        pageLists =
                            { oldPageLists |
                                timeEntryWithPager =
                                    { oldTimeEntryWithPager |
                                        timeEntries = []
                                    }
                            }
        --                , errors = (::) "There was a problem, the record(s) could not be retrieved!" model.errors
                        , tableState = Table.initialSort "ID"
                    } ! []

        ModalMsg subMsg ->
            model ! []
--            let
--                cmd =
--                    case subMsg |> Modal.update model.query of
--                        ( False, _ ) ->
--                            Cmd.none
--
--                        ( True, _ ) ->
--                            Maybe.withDefault new model.editing
--                                |> Request.TimeEntry.delete url
--                                |> Http.toTask
--                                |> Task.attempt Deleted
--            in
--            { model |
--                showModal = ( False, Nothing )
--            } ! [ cmd ]

        NewPage page ->
            model !
            [ page
                |> Maybe.withDefault -1
                |> Request.TimeEntry.page url
                |> Http.send ( \result -> result |> TimeEntries |> Fetch )
            ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just timeEntry ->
                            Validate.TimeEntry.errors timeEntry

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just timeEntry ->
                            ( None
                            , { timeEntry | specialist = model.user.id }
                                |> Request.TimeEntry.post url
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

        Posted ( Ok timeEntry ) ->
            let
                timeEntryWithPager = oldPageLists.timeEntryWithPager

                entries =
                    case model.editing of
                        Nothing ->
                            timeEntryWithPager.timeEntries

                        Just newTimeEntry ->
                            timeEntryWithPager.timeEntries
                                |> (::)
                                    { newTimeEntry |
                                        id = timeEntry.id
                                        , specialist = model.user.id
                                    }
            in
            { model |
                editing = Nothing
                , pageLists =
                    { oldPageLists |
                        timeEntryWithPager =
                            { timeEntryWithPager |
                                timeEntries = entries
                            }
                    }
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

                        Just timeEntry ->
                            Validate.TimeEntry.errors timeEntry

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just timeEntry ->
                            ( None
                            , Request.TimeEntry.put url timeEntry
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

        Putted ( Ok timeEntry ) ->
            let
                timeEntryWithPager = oldPageLists.timeEntryWithPager

                timeEntries =
                    case model.editing of
                        Nothing ->
                            timeEntryWithPager.timeEntries

                        Just newTimeEntry ->
                            timeEntryWithPager.timeEntries
                                |> List.filter ( \m -> timeEntry.id /= m.id )
                                |> (::)
                                    { newTimeEntry | id = timeEntry.id }
            in
            { model |
                editing = Nothing
                , pageLists =
                    { oldPageLists |
                        timeEntryWithPager =
                            { timeEntryWithPager |
                                timeEntries = timeEntries
                            }
                    }
            } ! []

        Putted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be updated!" model.errors
            } ! []

        Search ->
            { model |
                showModal = ( True, Nothing |> Modal.Search Data.Search.TimeEntry model.query |> Just )
            } ! []

        Select selectType consumer selection ->
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
                    ( { consumer | consumer = selectionToInt } |> newModel ) ! []

                Form.ServiceCodeID ->
                    ( { consumer | serviceCode = selectionToInt } |> newModel ) ! []

                _ ->
                    model ! []

--        SelectConsumer timeEntry consumerID ->
--            let
--                selectedConsumer =
--                    model.pageLists.consumers
--                    |> List.filter ( \m -> consumerID |> Form.toInt |> (==) m.id )
--                    |> List.head
--                    |> Maybe.withDefault Data.Consumer.new
--            in
--            { model |
--                editing = { timeEntry |
--                    consumer = consumerID |> Form.toInt
--                    , county = selectedConsumer.county
--                } |> Just
--            } ! []
--
--        SelectServiceCode timeEntry serviceCode ->
--            let
--                selectedServiceCode =
--                    model.pageLists.serviceCodes
--                    |> List.filter ( \m -> serviceCode |> Form.toInt |> (==) m.id )
--                    |> List.head
--                    |> Maybe.withDefault Data.ServiceCode.new
--            in
--            { model |
--                editing = { timeEntry |
--                    serviceCode = serviceCode |> Form.toInt
--                } |> Just
--            } ! []

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
            [ h1 [] [ text "Time Entry" ]
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
    , query
    , tableState
    } as model ) =
    let
        editable : TimeEntry
        editable = case editing of
            Nothing ->
                new

            Just timeEntry ->
                timeEntry

        showList =
            case pageLists.timeEntryWithPager.timeEntries |> List.length of
                0 ->
                    div [] []
                _ ->
                    Table.view config tableState pageLists.timeEntryWithPager.timeEntries

        showPager =
            model.pageLists.timeEntryWithPager.pager |> Views.Pager.view NewPage
    in
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Time Entry" ]
            , showPager
            , showList
            , showPager
            , model.showModal
                |> Modal.view query
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



formRows : ( TimeEntry, Maybe Date, DatePicker.DatePicker, PageLists ) -> List ( Html Msg )
formRows ( editable, date, datePicker, pageLists ) =
    let
        focusedDate : Maybe Date
        focusedDate =
            case (/=) editable.serviceDate "" of
                True ->
                    editable.serviceDate |> Util.Date.unsafeFromString |> Just
                False ->
                    date
    in
    [ Form.select "Consumer"
        [ id "consumerSelection"
        , editable |> Select Form.ConsumerID |> onInput
        , autofocus True
        ] (
            pageLists.consumers
                |> List.map ( \m -> ( m.id |> toString, ( m.lastname ++ ", " ++ m.firstname ) ) )
                |> (::) ( "-1", "-- Select a consumer --" )
                |> List.map ( editable.consumer |> toString |> Form.option )
        )
    , div []
        [ label [] [ text "Service Date" ]
        , DatePicker.view focusedDate ( date |> settings ) datePicker
            |> Html.map DatePicker
        ]
    , Form.select "Service Code"
        [ id "serviceCodeSelection"
        , editable |> Select Form.ServiceCodeID |> onInput
        ] (
            pageLists.serviceCodes
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a service code --" )
                |> List.map ( editable.serviceCode |> toString |> Form.option )
        )
    , Form.float "Hours"
        [ editable.hours |> toString |> value
        , onInput ( SetFormValue (\v -> { editable | hours = Form.toFloat v } ) )
        , step "0.25"
        ]
        []
    , Form.text "Description"
        [ value editable.description
        , onInput ( SetFormValue ( \v -> { editable | description = v } ) )
        ]
        []
    , Form.text "County"
        [ editable.county |> toString |> value
        , disabled True
        ]
        []
    , Form.text "Contract Type"
        [ value editable.contractType
        , disabled True
        ]
        []
    , Form.text "Billing Code"
        [ value editable.billingCode
        , onInput ( SetFormValue ( \v -> { editable | billingCode = v } ) )
        ]
        []
    ]



-- TABLE CONFIGURATION


config : Table.Config TimeEntry Msg
config =
    Table.customConfig
    { toId = .id >> toString
    , toMsg = SetTableState
    , columns =
        [ Table.intColumn "Consumer" .consumer
        , Table.stringColumn "Service Date" .serviceDate
        , Table.intColumn "Service Code" .serviceCode
        , Table.floatColumn "Hours" .hours
        , Table.stringColumn "Description" .description
        , Table.intColumn "County" .county
        , Table.stringColumn "Contract Type" .contractType
        , Table.stringColumn "Billing Code" .billingCode
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        ]
    , customizations = defaultCustomizations
    }


customColumn : ( TimeEntry -> Table.HtmlDetails Msg ) -> Table.Column TimeEntry Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( TimeEntry -> msg ) -> String -> TimeEntry -> Table.HtmlDetails msg
viewButton msg name timeEntry =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| timeEntry ] [ text name ]
        ]


