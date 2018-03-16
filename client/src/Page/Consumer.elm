module Page.Consumer exposing (Model, Msg, init, update, view)

import Data.City exposing (City)
import Data.Consumer exposing (Consumer, ConsumerWithPager, new)
import Data.County exposing (County)
import Data.Pager exposing (Pager)
import Data.ServiceCode exposing (ServiceCode)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onCheck, onClick, onInput, onSubmit)
import Http
import Request.City
import Request.Consumer
import Request.County
import Request.ServiceCode
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Date
import Validate.Consumer
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal
import Views.Pager



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
    , countyData : CountyData
    , serviceCodes : List ServiceCode
    , consumers : List Consumer
    , pager : Pager
    }


type alias CountyData
    = ( List County, List City )


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
    , countyData = ( [], [] )
    , serviceCodes = []
    , consumers = []
    , pager = Data.Pager.new
    } ! [ Cmd.map DatePicker datePickerFx
    , Request.ServiceCode.list url |> Http.send ( \result -> result |> ServiceCodes |> Fetch )
    , Request.County.list url |> Http.send ( \result -> result |> Counties |> Fetch )
    , 0 |> Request.Consumer.page url |> Http.send ( \result -> result |> Consumers |> Fetch )
    ]


-- UPDATE


type FetchedData
    = Cities ( Result Http.Error ( List City ) )
    | Consumers ( Result Http.Error ConsumerWithPager )
    | Counties ( Result Http.Error ( List County ) )
    | ServiceCodes ( Result Http.Error ( List ServiceCode ) )


type Msg
    = Add
    | Cancel
    | DatePicker DatePicker.Msg
    | Delete Consumer
    | Deleted ( Result Http.Error Int )
    | Edit Consumer
    | Fetch FetchedData
    | ModalMsg Modal.Msg
    | NewPage ( Maybe Int )
    | Post
    | Posted ( Result Http.Error Consumer )
    | Put
    | Putted ( Result Http.Error Consumer )
    | Select Form.Selection Consumer String
    | SetCheckboxValue ( Bool -> Consumer ) Bool
    | SetFormValue ( String -> Consumer ) String
    | SetTableState Table.State


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
            { model |
                editing = Just consumer
                , showModal = ( True , Modal.Delete |> Just )
            } ! []

        Deleted ( Ok id ) ->
            { model |
                consumers = model.consumers |> List.filter ( \m -> id /= m.id )
            } ! []

        Deleted ( Err err ) ->
            { model |
                action = None
--                , errors = (::) "There was a problem, the record could not be deleted!" model.errors
            } ! []

        Edit consumer ->
            { model |
                action = Editing
                , editing = Just consumer
            -- Fetch the county's zip codes to set the zip code drop-down to the correct value.
            } ! [ consumer.county |> toString |> Request.City.get url |> Http.send ( \result -> result |> Cities |> Fetch ) ]

        Fetch result ->
            case result of
                Cities ( Ok cities ) ->
                    { model |
                        countyData = ( model.countyData |> Tuple.first, cities )
                        , tableState = Table.initialSort "ID"
                    } ! []

                Cities ( Err err ) ->
                    { model |
                        countyData = ( model.countyData |> Tuple.first, [] )
                        , tableState = Table.initialSort "ID"
                    } ! []

                Consumers ( Ok consumers ) ->
                    { model |
                        consumers = consumers.consumers
                        , pager = consumers.pager
                        , tableState = Table.initialSort "ID"
                    } ! []

                Consumers ( Err err ) ->
                    { model |
                        consumers = []
                        , tableState = Table.initialSort "ID"
                    } ! []

                Counties ( Ok counties ) ->
                    { model |
                        countyData = ( counties, model.countyData |> Tuple.second )
                        , tableState = Table.initialSort "ID"
                    } ! []

                Counties ( Err err ) ->
                    { model |
                        countyData = ( [], model.countyData |> Tuple.second )
                        , tableState = Table.initialSort "ID"
                    } ! []

                ServiceCodes ( Ok serviceCodes ) ->
                    { model |
                        serviceCodes = serviceCodes
                        , tableState = Table.initialSort "ID"
                    } ! []

                ServiceCodes ( Err err ) ->
                    { model |
                        serviceCodes = []
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
                                |> Request.Consumer.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
            in
            { model |
                showModal = ( False, Nothing )
            } ! [ cmd ]

        NewPage page ->
            model !
            [ page
                |> Maybe.withDefault -1
                |> Request.Consumer.page url
                |> Http.send ( \result -> result |> Consumers |> Fetch )
            ]

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
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok consumer ) ->
            let
                consumers =
                    case model.editing of
                        Nothing ->
                            model.consumers

                        Just newConsumer ->
                            model.consumers
                                |> (::) { newConsumer | id = consumer.id }
            in
            { model |
                consumers = consumers
                , editing = Nothing
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

                        Just consumer ->
                            Validate.Consumer.errors consumer

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just consumer ->
                            ( None
                            , Request.Consumer.put url consumer
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

        Putted ( Ok consumer ) ->
            let
                consumers =
                    case model.editing of
                        Nothing ->
                            model.consumers

                        Just newConsumer ->
                            model.consumers
                                |> List.filter ( \m -> consumer.id /= m.id )
                                |> (::) { newConsumer | id = consumer.id }
            in
                { model |
                    consumers = consumers
                    , editing = Nothing
                } ! []

        Putted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be updated!" model.errors
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
                Form.CountyID ->
                    ( { consumer | county = selectionToInt } |> newModel ) ! []

                Form.ServiceCodeID ->
                    ( { consumer | serviceCode = selectionToInt } |> newModel ) ! []

                Form.ZipID ->
                    ( { consumer | zip = selection } |> newModel ) ! []

                _ ->
                    model ! []

--        SelectCounty consumer countyID ->
--            { model |
--                editing = { consumer | county = countyID |> Form.toInt } |> Just
--                , disabled = False
--            -- Fetch the county's zip codes to set the zip code drop-down to the correct value.
--            } ! [ countyID |> Request.City.get url |> Http.send ( \result -> result |> Cities |> Fetch ) ]
--
--        SelectServiceCode consumer serviceCode ->
--            { model |
--                editing = { consumer | serviceCode = Form.toInt serviceCode } |> Just
--                , disabled = False
--            } ! []
--
--        SelectZip consumer zip ->
--            { model |
--                editing = { consumer | zip = zip } |> Just
--                , disabled = False
--            } ! []

        SetCheckboxValue setBoolValue b ->
            { model |
                editing = setBoolValue b |> Just
                , disabled = False
            } ! []

        SetFormValue setFormValue s ->
            { model |
                editing = setFormValue s |> Just
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
            [ h1 [] [ text "Consumer" ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView (
    { action
    , countyData
    , date
    , datePicker
    , disabled
    , editing
    , tableState
    , serviceCodes
    , consumers
    } as model ) =
    let
        editable : Consumer
        editable = case editing of
            Nothing ->
                new

            Just consumer ->
                consumer

        showList =
            case consumers |> List.length of
                0 ->
                    div [] []
                _ ->
                    consumers
                        |> Table.view ( model |> config ) tableState

        showPager =
            model.pager |> Views.Pager.view NewPage
    in
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Consumer" ]
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
                    ( ( editable, date, datePicker, serviceCodes, countyData ) |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]

        Editing ->
            [ form [ onSubmit Put ]
                ( (++)
                    ( ( editable, date, datePicker, serviceCodes, countyData ) |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]


formRows : ( Consumer, Maybe Date, DatePicker.DatePicker, List ServiceCode, CountyData ) -> List ( Html Msg )
formRows ( editable, date, datePicker, serviceCodes, countyData ) =
    let
        focusedDate : Maybe Date
        focusedDate =
            case (/=) editable.dischargeDate "" of
                True ->
                    editable.dischargeDate |> Util.Date.unsafeFromString |> Just
                False ->
                    date
    in
    [ Form.text "First Name"
        [ value editable.firstname
        , onInput ( SetFormValue ( \v -> { editable | firstname = v } ) )
        , autofocus True
        ]
        []
    , Form.text "Last Name"
        [ value editable.lastname
        , onInput ( SetFormValue ( \v -> { editable | lastname = v } ) )
        ]
        []
    , Form.checkbox "Active"
        [ checked editable.active
        , onCheck ( SetCheckboxValue ( \v -> { editable | active = v } ) )
        ]
        []
    , Form.select "County"
        [ id "countySelection"
        , editable |> Select Form.CountyID |> onInput
        ] (
            countyData
                |> Tuple.first
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a county --" )
                |> List.map ( editable.county |> toString |> Form.option )
        )
    , Form.select "Service Code"
        [ id "serviceCodeSelection"
        , editable |> Select Form.ServiceCodeID |> onInput
        ] (
            serviceCodes
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a service code --" )
                |> List.map ( editable.serviceCode |> toString |> Form.option )
        )
    , Form.text "Funding Source"
        [ value editable.fundingSource
        , onInput ( SetFormValue ( \v -> { editable | fundingSource = v } ) )
        ]
        []
    , Form.select "Zip Code"
        [ id "zipCodeSelection"
        , editable |> Select Form.ZipID |> onInput
        ] (
            countyData
                |> Tuple.second
                |> List.map ( \m -> ( m.zip, m.zip ) )
                |> (::) ( "-1", "-- Select a zip code --" )
                |> List.map ( editable.zip |> Form.option )
        )
    , Form.text "BSU"
        [ value editable.bsu
        , onInput ( SetFormValue (\v -> { editable | bsu = v } ) )
        ]
        []
    , Form.text "Recipient ID"
        [ value editable.recipientID
        , onInput ( SetFormValue ( \v -> { editable | recipientID = v } ) )
        ]
        []
    , Form.text "DIA Code"
        [ value editable.diaCode
        , onInput ( SetFormValue ( \v -> { editable | diaCode = v } ) )
        ]
        []
    , Form.float "Copay"
        [ editable.copay |> toString |> value
        , onInput ( SetFormValue ( \v -> { editable | copay = Form.toFloat v } ) )
        ]
        []
    , div []
        [ label [] [ text "Discharge Date" ]
        , DatePicker.view focusedDate ( date |> settings ) datePicker
            |> Html.map DatePicker
        ]
    , Form.text "Other"
        [ value editable.other
        , onInput ( SetFormValue ( \v -> { editable | other = v } ) )
        ]
        []
    ]

-- TABLE CONFIGURATION


config : Model -> Table.Config Consumer Msg
config model =
    Table.customConfig
    { toId = .id >> toString
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "First Name" .firstname
        , Table.stringColumn "Last Name" .lastname
        , customColumn viewCheckbox "Active"
        , Table.stringColumn "County" (
            .county
                >> ( \id ->
                    Tuple.first model.countyData |> List.filter ( \m -> m.id |> (==) id )
                    )
                >> List.head
                >> Maybe.withDefault { id = -1, name = "" }
                >> .name
        )
        , Table.intColumn "Service Code" .serviceCode
        , Table.stringColumn "Funding Source" .fundingSource
        , Table.stringColumn "Zip Code" .zip
        , Table.stringColumn "BSU" .bsu
        , Table.stringColumn "Recipient ID" .recipientID
        , Table.stringColumn "DIA Code" .diaCode
        , Table.floatColumn "Copay" .copay
        , Table.stringColumn "Discharge Date" .dischargeDate
        , Table.stringColumn "Other" .other
        , customColumn ( viewButton Edit "Edit" ) ""
        , customColumn ( viewButton Delete "Delete" ) ""
        ]
    , customizations = defaultCustomizations
    }


customColumn : ( Consumer -> Table.HtmlDetails Msg ) -> String -> Table.Column Consumer Msg
customColumn viewElement header =
    Table.veryCustomColumn
        { name = header
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( Consumer -> msg ) -> String -> ( Consumer -> Table.HtmlDetails msg )
viewButton msg name consumer =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| consumer ] [ text name ]
        ]


viewCheckbox : Consumer -> Table.HtmlDetails Msg
viewCheckbox { active } =
  Table.HtmlDetails []
    [ input [ checked active, disabled True, type_ "checkbox" ] []
    ]


