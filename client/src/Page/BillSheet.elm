module Page.BillSheet exposing (Model, Msg, init, update, view)

import Data.BillSheet exposing (BillSheet, new)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Request.BillSheet
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Date
import Validate.BillSheet
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal



-- MODEL


type alias Model =
    { errors : List ( Validate.BillSheet.Field, String )
    , tableState : Table.State
    , action : Action
    , editing : Maybe BillSheet
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , date : Maybe Date
    , datePicker : DatePicker.DatePicker
    , billsheets : List BillSheet
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
    , billsheets = []
    } ! [ Cmd.map DatePicker datePickerFx
    , Request.BillSheet.get url |> Http.send FetchedBillSheets
    ]



-- UPDATE


type Msg
    = Add
    | Cancel
    | DatePicker DatePicker.Msg
    | Delete BillSheet
    | Deleted ( Result Http.Error () )
    | Edit BillSheet
    | FetchedBillSheets ( Result Http.Error ( List BillSheet ) )
    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error BillSheet )
    | Put
    | Putted ( Result Http.Error BillSheet )
    | SetFormValue ( String -> BillSheet ) String
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
            model ! []
--            { model |
--                showModal =
--                    ( True
--                    , billsheet |> Modal.Delete |> Just
--                    )
--            } ! []
--            let
--                subCmd =
--                    Request.BillSheet.delete url billsheet
--                        |> Http.toTask
--                        |> Task.attempt Deleted
--            in
--                { model |
--                    action = None
--                    , editing = Nothing
--                } ! [ subCmd ]

        Deleted ( Ok billsheet ) ->
            model ! []

        Deleted ( Err err ) ->
            let
                gg = (Debug.log "err" err)
            in
            model ! []

        Edit billsheet ->
            { model |
                action = Editing
                , editing = Just billsheet
            } ! []

        FetchedBillSheets ( Ok billsheets ) ->
            { model |
                billsheets = billsheets
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedBillSheets ( Err err ) ->
            { model |
                billsheets = []
                , tableState = Table.initialSort "ID"
            } ! []

        ModalMsg subMsg ->
--            let
--                ( bool, cmd ) =
--                    ( \billsheet ->
--                        Request.BillSheet.delete url billsheet
--                            |> Http.toTask
--                            |> Task.attempt Deleted
--                    ) |> Modal.update subMsg
--            in
--            { model |
--                showModal = ( bool, Nothing )
--            } ! [ cmd ]
            model ! []

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
                    , editing = Nothing
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok billsheet ) ->
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
--                        Just billsheet ->
--                            Validate.BillSheet.errors billsheet
--
--                ( action, subCmd ) = if errors |> List.isEmpty then
--                    case model.editing of
--                        Nothing ->
--                            ( None, Cmd.none )
--
--                        Just billsheet ->
--                            ( None
--                            , Request.BillSheet.put url billsheet
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

        Putted ( Ok specialist ) ->
            model ! []
--            let
--                specialists =
--                    case model.editing of
--                        Nothing ->
--                            model.specialists
--
--                        Just newSpecialist ->
--                            model.specialists
--                                |> List.filter ( \m -> specialist.id /= m.id )
--                                |> (::)
--                                    { newSpecialist |
--                                        id = specialist.id
--                                        , password = specialist.password
--                                    }
--            in
--                { model |
--                    specialists = specialists
--                    , editing = Nothing
--                } ! []

        Putted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be updated!" model.errors
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
    , tableState
    , billsheets
    } as model ) =
    let
        editable : BillSheet
        editable = case editing of
            Nothing ->
                new

            Just billsheet ->
                billsheet
    in
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Bill Sheet" ]
            , Table.view config tableState billsheets
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


formRows : ( BillSheet, Maybe Date, DatePicker.DatePicker ) -> List ( Html Msg )
formRows ( editable, date, datePicker ) =
    [ Form.text "ID"
        [ value editable.id
        , disabled True
        ]
        []
    , Form.text "Recipient ID"
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
    , Form.text "Consumer"
        [ value editable.consumer
        , onInput ( SetFormValue (\v -> { editable | consumer = v } ) )
        ]
        []
    , Form.text "Status"
        [ value editable.status
        , onInput ( SetFormValue (\v -> { editable | status = v } ) )
        ]
        []
    , Form.text "Confirmation"
        [ value editable.confirmation
        , onInput ( SetFormValue (\v -> { editable | confirmation = v } ) )
        ]
        []
    , Form.text "Service"
        [ value editable.service
        , onInput ( SetFormValue (\v -> { editable | service = v } ) )
        ]
        []
    , Form.text "County"
        [ value editable.county
        , onInput ( SetFormValue (\v -> { editable | county = v } ) )
        ]
        []
    , Form.text "Specialist"
        [ value editable.specialist
        , onInput ( SetFormValue (\v -> { editable | county = v } ) )
        ]
        []
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
    { toId = .id
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "ID" .id
        , Table.stringColumn "Recipient ID" .recipientID
        , Table.stringColumn "Service Date" .serviceDate
        , Table.floatColumn "Billed Amount" .billedAmount
        , Table.stringColumn "Consumer" .consumer
        , Table.stringColumn "Status" .status
        , Table.stringColumn "Confirmation" .confirmation
        , Table.stringColumn "Service" .service
        , Table.stringColumn "County" .county
        , Table.stringColumn "Specialist" .specialist
        , Table.stringColumn "Record Number" .recordNumber
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : BillSheet -> List ( Attribute Msg )
toRowAttrs { id } =
    [ style [ ( "background", "white" ) ]
    ]


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


