module Page.BillSheet exposing (Model, Msg, init, update, view)

import Data.Search exposing (Search, Query, ViewLists, fmtEquality)
import Data.BillSheet exposing (BillSheet, BillSheetWithPager, new)
import Data.Consumer exposing (Consumer)
import Data.County exposing (County)
import Data.Pager exposing (Pager)
import Data.ServiceCode exposing (ServiceCode)
import Data.Session exposing (Session)
import Data.Status exposing (Status)
import Data.User exposing (User)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, for, hidden, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Modal.Search
import Page.BillSheet.BillSheet
import Page.BillSheet.TimeEntry
import Request.BillSheet
import Request.Consumer
import Request.County
import Request.Specialist
import Request.ServiceCode
import Request.Status
import Table exposing (defaultCustomizations)
import Task exposing (Task)
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
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , viewLists : ViewLists
    , query : Maybe Query
    , pagerState : Pager
    , subModel :
        { tableState : Table.State
        , editing : Maybe BillSheet
        , disabled : Bool
        , date : Maybe Date
        , datePicker : DatePicker.DatePicker
        }
    , user : User
    }



init : String -> User -> ( Model, Cmd Msg )
init url user =
    let
        ( subModel, cmd ) =
            case user.authLevel of
                1 ->
                    ( Page.BillSheet.BillSheet.init,
                        [ Request.Consumer.list url |> Http.send ( Consumers >> Fetch )
                        , Request.County.list url |> Http.send ( Counties >> Fetch )
                        , Request.ServiceCode.list url |> Http.send ( ServiceCodes >> Fetch )
                        , Request.Specialist.list url |> Http.send ( Specialists >> Fetch )
                        , Request.Status.list url |> Http.send ( Statuses >> Fetch )
                        , 0 |> Request.BillSheet.page url "" |> Http.send ( BillSheets >> Fetch )
                        ]
                    )

                _ ->
                    ( user |> Page.BillSheet.TimeEntry.init,
                        [ Request.Consumer.list url |> Http.send ( Consumers >> Fetch )
                        , Request.County.list url |> Http.send ( Counties >> Fetch )
                        , Request.ServiceCode.list url |> Http.send ( ServiceCodes >> Fetch )
                        , Request.BillSheet.query url ( (++) "specialist=" ( user.id |> toString ) ) |> Http.send ( BillSheets >> Fetch )
                        ]
                    )
    in
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , disabled = True
    , showModal = ( False, Nothing )
    , viewLists =
        { billsheets = Nothing
        , consumers = Nothing
        , counties = Nothing
        , serviceCodes = Nothing
        , specialists = Nothing
        , status = Nothing
        }
    , query = Nothing
    , pagerState = Data.Pager.new
    , subModel = subModel
    , user = user
    } ! cmd



-- UPDATE

type FetchedData
    = BillSheets ( Result Http.Error BillSheetWithPager )
    | Consumers ( Result Http.Error ( List Consumer ) )
    | Counties ( Result Http.Error ( List County ) )
    | ServiceCodes ( Result Http.Error ( List ServiceCode ) )
    | Specialists ( Result Http.Error ( List User ) )
    | Statuses ( Result Http.Error ( List Status ) )


type Msg
    = Add
    | Cancel
    | ClearSearch
    | Delete BillSheet
    | Deleted ( Result Http.Error Int )
    | Edit BillSheet
    | Fetch FetchedData
    | BillSheetTimeEntryMsg Page.BillSheet.TimeEntry.Msg
    | BillSheetBillSheetMsg Page.BillSheet.BillSheet.Msg
    | ModalMsg Modal.Msg
    | NewPage ( Maybe Int )
    | Post
    | Posted ( Result Http.Error BillSheet )
    | Put
    | Putted ( Result Http.Error BillSheet )
    | Query Query
    | Search ViewLists
    | SetTableState Table.State


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update url msg model =
    let
        oldViewLists = model.viewLists
        subModel = model.subModel
    in
    case msg of
        Add ->
            { model |
                action = Adding
                , disabled = True
            } ! []

        BillSheetTimeEntryMsg subMsg ->
            let
                ( m, cmd ) =
                    model.subModel
                        |> Page.BillSheet.TimeEntry.update subMsg
            in
            { model |
                disabled = False
                , subModel = m
            } ! [ Cmd.map BillSheetTimeEntryMsg cmd ]

        BillSheetBillSheetMsg subMsg ->
            let
                ( m, cmd ) =
                    subModel
                        |> Page.BillSheet.BillSheet.update subMsg
            in
            { model |
                disabled = False
                , subModel = m
            } ! [ Cmd.map BillSheetBillSheetMsg cmd ]

        Cancel ->
            { model |
                action = None
                , subModel = { subModel | editing = Nothing }
                , errors = []
            } ! []

        ClearSearch ->
            let
                whereClause =
                    if (==) model.user.authLevel 1
                    then ""
                    else (++) "specialist=" ( model.user.id |> toString )
            in
            { model |
                query = Nothing
            } ! [ 0
                    |> Request.BillSheet.page url whereClause
                    >> Http.send ( BillSheets >> Fetch )
                ]

        Delete billsheet ->
            { model |
                showModal = ( True , Modal.Delete |> Just )
                , subModel = { subModel | editing = billsheet |> Just }
            } ! []

        Deleted ( Ok id ) ->
            let
                billsheets =
                    case oldViewLists.billsheets of
                        Nothing ->
                            Nothing

                        Just billsheets ->
                            billsheets |> List.filter ( \m -> id /= m.id ) |> Just
            in
            { model |
                viewLists =
                    { oldViewLists |
                        billsheets = billsheets
                    }
                , subModel = { subModel | editing = Nothing }
            } ! []

        Deleted ( Err err ) ->
            { model |
                action = None
                , subModel = { subModel | editing = Nothing }
--                , errors = (::) "There was a problem, the record could not be deleted!" model.errors
            } ! []

        Edit billsheet ->
            { model |
                action = Editing
                , disabled = True
                , subModel = { subModel | editing = billsheet |> Just }
            } ! []

        Fetch result ->
            case result of
                BillSheets ( Ok billsheets ) ->
                    { model |
                        viewLists = { oldViewLists | billsheets = billsheets.billsheets |> Just }
                        , pagerState = billsheets.pager
                        , tableState = Table.initialSort "ID"
                    } ! []

                BillSheets ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | billsheets = Nothing }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Consumers ( Ok consumers ) ->
                    { model |
                        viewLists = { oldViewLists | consumers = consumers |> Just }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Consumers ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | consumers = Nothing }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Counties ( Ok counties ) ->
                    { model |
                        viewLists = { oldViewLists | counties = counties |> Just }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Counties ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | counties = Nothing }
                        , tableState = Table.initialSort "ID"
                    } ! []

                ServiceCodes ( Ok serviceCodes ) ->
                    { model |
                        viewLists = { oldViewLists | serviceCodes = serviceCodes |> Just }
                        , tableState = Table.initialSort "ID"
                    } ! []

                ServiceCodes ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | serviceCodes = Nothing }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Specialists ( Ok specialists ) ->
                    { model |
                        viewLists = { oldViewLists | specialists = specialists |> Just }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Specialists ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | specialists = Nothing }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Statuses ( Ok status ) ->
                    { model |
                        viewLists = { oldViewLists | status = status |> Just }
                        , tableState = Table.initialSort "ID"
                    } ! []

                Statuses ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | status = Nothing }
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
                            , Maybe.withDefault new model.subModel.editing
                                |> Request.BillSheet.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
                            )

                        {- Search Modal -}
                        ( False, Just query ) ->
                            let
                                -- Since there's so much common functionality shared by the BillSheet and
                                -- TimeEntry pages, we must always check to see which page is being viewed.
                                -- The BillSheet is an admin-only page, and thus should not be send a Specialist
                                -- in the where clause.
                                maybeInsertSpecialist query =
                                    if (==) model.user.authLevel 1
                                    then query
                                    else Dict.insert "specialist" ( model.user.id |> toString ) query
                            in
                            ( False
                            , Nothing
                            , query |> Just                     -- We need to save the search query for paging!
                            , Http.send ( BillSheets >> Fetch )
                                << Request.BillSheet.query url
                                << String.dropRight 5           -- Remove the trailing " AND ".
                                << Dict.foldl fmtEquality ""
                                << maybeInsertSpecialist
                                <| query
                            )

                        ( True, Just query ) ->
                            let
                                whichSearch =
                                    if (==) model.user.authLevel 1
                                    then Data.Search.BillSheet
                                    else Data.Search.TimeEntry
                            in
                            ( True
                            , model.viewLists |> Just
                                |> Modal.Search whichSearch model.query
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
                    case model.subModel.editing of
                        Nothing ->
                            []

                        Just billsheet ->
                            Validate.BillSheet.errors billsheet

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.subModel.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just billsheet ->
                            ( None
                            , { billsheet | specialist = model.user.id }
                                |> Request.BillSheet.post url
                                |> Http.toTask
                                |> Task.attempt Posted
                            )
                    else
                        ( Adding, Cmd.none )
            in
                { model |
                    action = action
                    , disabled = True
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok billsheet ) ->
            let
                billsheets =
                    case model.subModel.editing of
                        Nothing ->
                            oldViewLists.billsheets

                        Just newBillSheet ->
                            case oldViewLists.billsheets of
                                Nothing ->
                                    [ { newBillSheet | id = billsheet.id } ] |> Just

                                Just billsheets ->
                                    billsheets
                                        |> (::) { newBillSheet | id = billsheet.id }
                                        |> Just
            in
            { model |
                viewLists = { oldViewLists | billsheets = billsheets }
            } ! []

        Posted ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                errors = (::) ( Validate.BillSheet.ServerError, e ) model.errors
                , subModel = { subModel | editing = Nothing }
            } ! []

        Put ->
            let
                errors =
                    case model.subModel.editing of
                        Nothing ->
                            []

                        Just billsheet ->
                            Validate.BillSheet.errors billsheet

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.subModel.editing of
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
                    , disabled = True
                    , errors = errors
                } ! [ subCmd ]

        Putted ( Ok billsheet ) ->
            let
                billsheets =
                    case model.subModel.editing of
                        Nothing ->
                            oldViewLists.billsheets

                        Just newBillSheet ->
                            case oldViewLists.billsheets of
                                Nothing ->
                                    Nothing

                                Just billsheets ->
                                    billsheets
                                        |> List.filter ( \m -> billsheet.id /= m.id )
                                        |> (::)
                                            { newBillSheet |
                                                id = billsheet.id
                                                , specialist = model.user.id
                                            }
                                        |> Just
            in
            { model |
                viewLists = { oldViewLists | billsheets = billsheets }
                , subModel = { subModel | editing = Nothing }
            } ! []

        Putted ( Err err ) ->
            { model |
--                , errors = (::) "There was a problem, the record could not be updated!" model.errors
                subModel = { subModel | editing = Nothing }
            } ! []

        Query query ->
            model ! []

        Search viewLists ->
            let
                whichSearch =
                    if (==) model.user.authLevel 1
                    then Data.Search.BillSheet
                    else Data.Search.TimeEntry
            in
            { model |
                showModal =
                    ( True,
                    viewLists
                        |> Just
                        >> Modal.Search whichSearch model.query
                        >> Just
                    )
            } ! []

        SetTableState newState ->
            { model | tableState = newState
            } ! []



-- VIEW


view : Session -> Model -> Html Msg
view session model =
    let
        user =
            session.user
                |> Maybe.withDefault Data.User.new
    in
    section []
        ( (++)
            [ h1 [] [ ( if (==) user.authLevel 1 then "Bill Sheet" else "Time Entry" ) |> text ]
            , Errors.view model.errors
            ]
            ( model |> drawView )
        )


drawView : Model -> List ( Html Msg )
drawView model =
    let
        editable : BillSheet
        editable = case model.subModel.editing of
            Nothing ->
                new

            Just billsheet ->
                billsheet

        ( showList, isDisabled ) =
            case model.viewLists.billsheets of
                Nothing ->
                    ( div [] [], True )

                Just billsheets ->
                    case billsheets |> List.length of
                        0 ->
                            ( div [] [], True )
                        _ ->
                            ( billsheets
                                |> Table.view ( model |> config ) model.tableState
                            , False )

        showPager =
            model.pagerState |> Views.Pager.view NewPage

        hideClearTextButton =
            case model.query of
                Nothing ->
                    True

                Just _ ->
                    False
    in
    case model.action of
        None ->
            [ button [ Add |> onClick ] [ text "Add Bill Sheet" ]
            , button [ isDisabled |> Html.Attributes.disabled, model.viewLists |> Search |> onClick ] [ text "Search" ]
            , button [ hideClearTextButton |> hidden, ClearSearch |> onClick ] [ text "Clear Search" ]
            , showPager
            , showList
            , showPager
            , model.showModal
                |> Modal.view model.query
                |> Html.map ModalMsg
            ]

        Adding ->
            let
                l =
                    case model.user.authLevel of
                        1 ->
                            ( model.subModel |> Page.BillSheet.BillSheet.formRows model.viewLists |> List.map ( Html.map BillSheetBillSheetMsg ) )

                        _ ->
                            ( model.subModel |> Page.BillSheet.TimeEntry.formRows model.viewLists |> List.map ( Html.map BillSheetTimeEntryMsg ) )
            in
            [ form [ Post |> onSubmit ]
                ( (++)
                    l
                    [ Form.submit model.disabled Cancel ]
                )
            ]

        Editing ->
            let
                l =
                    case model.user.authLevel of
                        1 ->
                            ( model.subModel |> Page.BillSheet.BillSheet.formRows model.viewLists |> List.map ( Html.map BillSheetBillSheetMsg ) )

                        _ ->
                            ( model.subModel |> Page.BillSheet.TimeEntry.formRows model.viewLists |> List.map ( Html.map BillSheetTimeEntryMsg ) )
            in
            [ form [ Put |> onSubmit ]
                ( (++)
                    l
                    [ Form.submit False Cancel ]
                )
            ]



config : Model -> Table.Config BillSheet Msg
config model =
    let
        tableColumns =
            case model.user.authLevel of
                1 ->
                    Page.BillSheet.BillSheet.tableColumns

                _ ->
                    Page.BillSheet.TimeEntry.tableColumns
    in
    Table.customConfig
    { toId = .id >> toString
    , toMsg = SetTableState
    , columns = model.viewLists |> tableColumns customColumn viewButton viewCheckbox Edit Delete
    , customizations = defaultCustomizations
    }


customColumn : String -> ( BillSheet -> Table.HtmlDetails Msg ) -> Table.Column BillSheet Msg
customColumn colName viewElement =
    Table.veryCustomColumn
        { name = colName
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( BillSheet -> msg ) -> String -> BillSheet -> Table.HtmlDetails msg
viewButton msg name billsheet =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| billsheet ] [ text name ]
        ]


viewCheckbox : BillSheet -> Table.HtmlDetails Msg
viewCheckbox { hold } =
  Table.HtmlDetails []
    [ input [ checked hold, Html.Attributes.disabled True, type_ "checkbox" ] []
    ]


