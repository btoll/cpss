module Page.BillSheet exposing (Model, Msg, init, update, view)

import Data.BillSheet exposing (BillSheet, BillSheetWithPager, new)
import Data.Build exposing (Build)
import Data.Consumer exposing (Consumer)
import Data.County exposing (County)
import Data.Pager exposing (Pager)
import Data.Search exposing (Query, ViewLists, fmtDates, fmtEquality)
import Data.ServiceCode exposing (ServiceCode)
import Data.Session exposing (Session)
import Data.Status exposing (Status)
import Data.User exposing (User)
import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings, DateEvent(..))
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, class, for, hidden, id, style, type_, value)
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
import Search.BillSheet
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Date
import Validate.BillSheet
import Validate.TimeEntry
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal
import Views.Page exposing (ViewAction(..), pageTitle)
import Views.Pager


-- MODEL


type alias Model =
    { errors : List String
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



init : Build -> Session -> ( Model, Cmd Msg )
init build session =
    let
        url =
            build.url

        user =
            Maybe.withDefault Data.User.new session.user

        authLevel =
            user.authLevel

        userID =
            user.id |> toString

        ( whereClause, defaultQuery ) =
            user |> Search.BillSheet.defaultQuery

        ( subModel, cmd ) =
            case authLevel of
                1 ->
                    let
                        ( model, subCmd ) =
                            Page.BillSheet.BillSheet.init build.today
                    in
                    (
                        model
                        , [ Cmd.map BillSheetBillSheetMsg subCmd
                        , Request.Consumer.list url |> Http.send ( Consumers >> Fetch )
                        , Request.County.list url |> Http.send ( Counties >> Fetch )
                        , Request.ServiceCode.list url |> Http.send ( ServiceCodes >> Fetch )
                        , Request.Specialist.list url |> Http.send ( Specialists >> Fetch )
                        , Request.Status.list url |> Http.send ( Statuses >> Fetch )
                        , 0 |> Request.BillSheet.page url whereClause |> Http.send ( BillSheets >> Fetch )
                        ]
                    )

                _ ->
                    let
                        ( model, subCmd ) =
                            Page.BillSheet.TimeEntry.init build.today
                    in
                    (
                        model
                        , [ Cmd.map BillSheetTimeEntryMsg subCmd
                        , Request.Consumer.list url |> Http.send ( Consumers >> Fetch )
                        , Request.County.list url |> Http.send ( Counties >> Fetch )
                        , Request.ServiceCode.list url |> Http.send ( ServiceCodes >> Fetch )
                        , 0 |> Request.BillSheet.page url whereClause |> Http.send ( BillSheets >> Fetch )
                        ]
                    )
    in
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , disabled = True
    , showModal = ( True, Modal.Spinner |> Just )
    , viewLists =
        { billsheets = Nothing
        , consumers = Nothing
        , counties = Nothing
        , serviceCodes = Nothing
        , specialists = Nothing
        , status = Nothing
        }
    , query = defaultQuery
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
                , errors = []
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
            let
                today =
                    case subModel.date of
                        Nothing ->
                            ""

                        Just date ->
                            date |> Util.Date.simple
            in
            { model |
                action = None
                , subModel =
                    { subModel | editing =
                        { new | serviceDate =   {- We always want a default date in case none is selected when adding a new Billsheet/Time Entry -}
                            today
                        } |> Just
                    }
                , errors = []
            } ! []

        ClearSearch ->
            let
                ( whereClause, defaultQuery ) =
                    model.user |> Search.BillSheet.defaultQuery
            in
            { model |
                query = defaultQuery
            } ! [ 0
                    |> Request.BillSheet.page url whereClause
                    >> Http.send ( BillSheets >> Fetch )
                ]

        Delete billsheet ->
            { model |
                showModal = ( True , Nothing |> Modal.Delete Modal.Standard |> Just )
                , subModel = { subModel | editing = billsheet |> Just }
                , errors = []
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
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                action = None
                , errors = (::) e model.errors
                , subModel = { subModel | editing = Nothing }
            } ! []

        Edit billsheet ->
            { model |
                action = Editing
                , disabled = True
                , errors = []
                , subModel = { subModel | editing = billsheet |> Just }
            } ! []

        Fetch result ->
            case result of
                BillSheets ( Ok billsheets ) ->
                    { model |
                        viewLists = { oldViewLists | billsheets = billsheets.billsheets |> Just }
                        , pagerState = billsheets.pager
                        , showModal = ( False, Nothing )
                        , tableState = Table.initialSort "ID"
                    } ! []

                BillSheets ( Err err ) ->
                    { model |
                        viewLists = { oldViewLists | billsheets = Nothing }
                        , showModal = ( False, Nothing )
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
                            ( False
                            , Nothing
                            , model.query
                            , Cmd.none
                            )

                        ( True, Nothing ) ->
                            ( False
                            , Nothing
                            , model.query
                            , Maybe.withDefault new model.subModel.editing
                                |> Request.BillSheet.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
                                )

                        {- Search Modal -}
                        ( False, Just query ) ->
                            let
                                foldFn : String -> String -> String -> String
                                foldFn k v acc =
                                    case k of
                                        "billsheet.serviceDate" ->
                                            fmtDates v acc

                                        _ ->
                                            fmtEquality k v acc

                                {-
                                    Formats "01/22/2018" -> "2018-01-22"
                                    NOTE that we're formatting the date here but also on the server...
                                        this was done for expediency but should be revisited!
                                -}
                                formatDate : String -> String
                                formatDate s =
                                    let
                                        getDay : String
                                        getDay =
                                            (++)
                                                "-"
                                                ( String.slice 3 5 s )

                                        getMonth : String
                                        getMonth =
                                            (++)
                                                "-"
                                                ( String.slice 0 2 s )

                                        getYear : String
                                        getYear =
                                            (++)
                                                "20"
                                                ( String.slice 6 8 s )
                                    in
                                    (
                                        (++)
                                            getYear
                                            ( (++) getMonth getDay )
                                    )

                                -- This function swaps out random key strings for key strings that are in a type!!
                                --
                                -- Make sure to remove date entries at each `case` stage! The `foldFn` should only be switching on
                                -- "billsheet.serviceDate", which is the only date entry that should be in the dict!
                                -- (Note that the key values are NOT type fields and MUST be replaced by an actual field in the
                                -- BillSheet type!)
                                maybeInsertDates : Query -> Query
                                maybeInsertDates query =
                                    case query |> Dict.get "serviceDateFrom" of
                                        Nothing ->
                                            query
                                                |> Dict.remove "serviceDateTo"

                                        Just dateFrom ->
                                            case query |> Dict.get "serviceDateTo" of
                                                Nothing ->
                                                    query
                                                        |> Dict.remove "serviceDateFrom"

                                                Just dateTo ->
                                                    query
                                                    |> Dict.remove "serviceDateTo"
                                                    |> Dict.remove "serviceDateFrom"
                                                    |> Dict.insert
                                                        "billsheet.serviceDate"
                                                        ( "( billsheet.serviceDate between '"
                                                        ++ ( dateFrom |> formatDate )
                                                        ++ "' and '"
                                                        ++ ( dateTo |> formatDate )
                                                        ++ "')"
                                                        )

                                -- Since there's so much common functionality shared by the BillSheet and
                                -- TimeEntry pages, we must always check to see which page is being viewed.
                                -- The BillSheet is an admin-only page, and thus should not send a Specialist
                                -- in the where clause.
                                maybeInsertSpecialist : Query -> Query
                                maybeInsertSpecialist query =
                                    if (==) model.user.authLevel 1
                                    then query
                                    else Dict.insert "billsheet.specialist" ( model.user.id |> toString ) query

                                q =
                                    String.dropRight 5           -- Remove the trailing " AND ".
                                        << Dict.foldl foldFn ""
                                        << maybeInsertDates
                                        << maybeInsertSpecialist
                                        <| query
                            in
                            ( True
                            , Modal.Spinner |> Just
                            , query |> Just                     -- We need to save the search query for paging!
                            , Request.BillSheet.page url q 0
                                |> Http.send ( BillSheets >> Fetch )
                            )

                        ( True, Just query ) ->
                            ( True
                            , model.viewLists |> Just
                                |> Modal.Search Data.Search.BillSheet ( model.user |> Just ) model.query
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
                formatDate : String -> String
                formatDate s =
                    let
                        getDay : String
                        getDay =
                            (++)
                                "-"
                                ( String.slice 3 5 s )

                        getMonth : String
                        getMonth =
                            (++)
                                "-"
                                ( String.slice 0 2 s )

                        getYear : String
                        getYear =
                            (++)
                                "20"
                                ( String.slice 6 8 s )
                    in
                    (
                        (++)
                            getYear
                            ( (++) getMonth getDay )
                    )

                maybeInsertDates : Query -> Query
                maybeInsertDates query =
                    case query |> Dict.get "serviceDateFrom" of
                        Nothing ->
                            query
                                |> Dict.remove "serviceDateTo"

                        Just dateFrom ->
                            case query |> Dict.get "serviceDateTo" of
                                Nothing ->
                                    query
                                        |> Dict.remove "serviceDateFrom"

                                Just dateTo ->
                                    query
                                    |> Dict.remove "serviceDateTo"
                                    |> Dict.remove "serviceDateFrom"
                                    |> Dict.insert
                                        "billsheet.serviceDate"
                                        ( "( billsheet.serviceDate between '"
                                        ++ ( dateFrom |> formatDate )
                                        ++ "' and '"
                                        ++ ( dateTo |> formatDate )
                                        ++ "')"
                                        )

                foldFn : String -> String -> String -> String
                foldFn k v acc =
                    case k of
                        "billsheet.serviceDate" ->
                            fmtDates v acc

                        _ ->
                            fmtEquality k v acc

                s =
                    model.query
                        |> Maybe.withDefault Dict.empty
                        |> maybeInsertDates
                        |> Dict.foldl foldFn ""
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
                            if model.user.authLevel == 1
                            then Validate.BillSheet.errors billsheet
                            else Validate.TimeEntry.errors billsheet

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.subModel.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just billsheet ->
                            let
                                -- Note that the specialist is inserted into the model via a drop-down selection box
                                -- in the Admin billsheet view!
                                --
                                -- The `realSpecialist` is needed b/c the server needs to know who the real user is who
                                -- performed the action (analogous to linux' real user id).  This is b/c the server must
                                -- allow an Admin to back date any billsheet, and the specialist field cannot be used for
                                -- the check since the Admin can assign any specialist to the billsheet just created.
                                bs =
                                    if model.user.authLevel == 2
                                    then { billsheet |
                                        specialist = model.user.id
                                        , realSpecialist = model.user.id
                                        }
                                    else { billsheet |
                                        realSpecialist = model.user.id
                                        }
                            in
                            ( Adding    -- Keep on Adding view in case server returns an error, i.e., trying to backdate a Service Date.
                            , bs
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
                                        |> (::)
                                            { newBillSheet |
                                                id = billsheet.id
                                                , formattedDate = newBillSheet.serviceDate
                                            }
                                        |> Just
            in
            { model |
                action = None
                , subModel = { subModel | editing = Nothing }
                , viewLists = { oldViewLists | billsheets = billsheets }
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
                errors = (::) e model.errors
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
                            ( Editing    -- Keep on Adding view in case server returns an error, i.e., trying to backdate a Service Date.
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
                action = None
                , viewLists = { oldViewLists | billsheets = billsheets }
                , subModel = { subModel | editing = Nothing }
            } ! []

        Putted ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                errors = (::) e model.errors
            } ! []

        Query query ->
            model ! []

        Search viewLists ->
            { model |
                showModal =
                    ( True,
                    viewLists
                        |> Just
                        >> Modal.Search Data.Search.BillSheet ( model.user |> Just ) model.query
                        >> Just
                    )
                , errors = []
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
            [ h1 [] [ ( if (==) user.authLevel 1 then "Bill Sheet" else "Time Entry" ) |> pageTitle model.action |> text ]
            , Errors.view model.errors
            ]
            ( model |> drawView )
        )


drawView : Model -> List ( Html Msg )
drawView model =
    let
        showList =
            case model.viewLists.billsheets of
                Nothing ->
                    div [] []

                Just billsheets ->
                    case billsheets |> List.length of
                        0 ->
                            div [] []
                        _ ->
                            billsheets
                                |> Table.view ( model |> config ) model.tableState

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
            [ div [ "buttons" |> class ]
                [ button [ Add |> onClick ] [ ( if (==) model.user.authLevel 1 then "Add Bill Sheet" else "Add Time Entry" ) |> text ]
                , button [ model.viewLists |> Search |> onClick ] [ text "Search" ]
                , button [ hideClearTextButton |> hidden, ClearSearch |> onClick ] [ text "Clear Search" ]
                ]
            , showPager
            , showList
            , showPager
            , model.showModal
                |> Modal.view ( model.user |> Just ) model.query
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

        _ ->
            [ div [] [] ]



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
    , columns = model.viewLists |> tableColumns customColumn viewButton Edit Delete
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


