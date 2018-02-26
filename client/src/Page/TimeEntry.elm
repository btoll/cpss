module Page.TimeEntry exposing (Model, Msg, init, update, view)

import Data.Consumer exposing (Consumer)
import Data.Pager exposing (Pager)
import Data.Session exposing (Session)
import Data.TimeEntry as TimeEntry exposing (TimeEntry, TimeEntryWithPager, new)
import Data.User exposing (User)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, step, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Request.Consumer
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
        , consumers = []
        }
    , user = user
    } ! [ Cmd.map DatePicker datePickerFx
        , Request.Consumer.list url |> Http.send FetchedConsumers
        , 0 |> Request.TimeEntry.page url |> Http.send FetchedTimeEntries
        ]



-- UPDATE


type Msg
    = Add
    | Cancel
    | DatePicker DatePicker.Msg
    | Delete TimeEntry
    | Deleted ( Result Http.Error Int )
    | Edit TimeEntry
    | FetchedConsumers ( Result Http.Error ( List Consumer ) )
    | FetchedTimeEntries ( Result Http.Error TimeEntryWithPager )
    | ModalMsg Modal.Msg
    | PagerMsg Views.Pager.Msg
    | Post
    | Posted ( Result Http.Error TimeEntry )
    | Put
    | Putted ( Result Http.Error TimeEntry )
    | SelectConsumer TimeEntry String
    | SetFormValue ( String -> TimeEntry ) String
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

        FetchedTimeEntries ( Ok timeEntries ) ->
            let
                oldTimeEntryWithPager = oldPageLists.timeEntryWithPager
                newTimeEntries = { oldTimeEntryWithPager | timeEntries = timeEntries.timeEntries }
            in
            { model |
                pageLists = { oldPageLists | timeEntryWithPager = newTimeEntries }
--                , pager = timeEntries.pager
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedTimeEntries ( Err err ) ->
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
            let
                cmd =
                    case ( subMsg |> Modal.update ) of
                        False ->
                            Cmd.none

                        True ->
                            Maybe.withDefault new model.editing
                                |> Request.TimeEntry.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
            in
            { model |
                showModal = ( False, Nothing )
            } ! [ cmd ]

        PagerMsg subMsg ->
            model !
            [ subMsg
                |>Views.Pager.update ( model.pageLists.timeEntryWithPager.pager.currentPage, model.pageLists.timeEntryWithPager.pager.totalPages )
                |> Request.TimeEntry.page url
                |> Http.send FetchedTimeEntries
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

        SelectConsumer timeEntry consumerID ->
            let
                selectedConsumer =
                    model.pageLists.consumers
                    |> List.filter ( \m -> consumerID |> Form.toInt |> (==) m.id )
                    |> List.head
                    |> Maybe.withDefault Data.Consumer.new
            in
            { model |
                editing = { timeEntry |
                    consumer = consumerID |> Form.toInt
                    , county = selectedConsumer.county
                } |> Just
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
    , tableState
    } as model ) =
    let
        pager : Pager
        pager =
            model.pageLists.timeEntryWithPager.pager

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

        showPager : Html Msg
        showPager =
            if 1 |> (>) pager.totalPages then
                pager.currentPage |> Views.Pager.view pager.totalPages |> Html.map PagerMsg
            else
                div [] []
    in
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Time Entry" ]
            , showPager
            , showList
            , showPager
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
        , editable |> SelectConsumer |> onInput
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
    , Form.text "Service Code"
        [ value editable.serviceCode
        , onInput ( SetFormValue ( \v -> { editable | serviceCode = v } ) )
        ]
        []
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
    , Form.text "County Code"
        [ value editable.countyCode
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
        , Table.stringColumn "Service Code" .serviceCode
        , Table.floatColumn "Hours" .hours
        , Table.stringColumn "Description" .description
        , Table.intColumn "County" .county
        , Table.stringColumn "County Code" .countyCode
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


