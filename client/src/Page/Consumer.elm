module Page.Consumer exposing (Model, Msg, init, update, view)

import Bitwise
import Data.Search exposing (Query, fmtFuzzyMatch)
import Data.City exposing (City)
import Data.Consumer exposing (Consumer, ConsumerWithPager, new, newServiceCode)
import Data.County exposing (County)
import Data.DIA exposing (DIA)
import Data.FundingSource exposing (FundingSource)
import Data.Pager exposing (Pager)
import Data.ServiceCode exposing (ServiceCode)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, text)
import Html.Attributes exposing (action, autofocus, checked, class, for, hidden, id, style, type_, value)
import Html.Events exposing (onCheck, onClick, onInput, onSubmit)
import Http
import Request.City
import Request.Consumer
import Request.County
import Request.DIA
import Request.FundingSource
import Request.ServiceCode
import Search.Consumer
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Validate.Consumer
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
    , editing : Maybe Consumer
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , countyData : CountyData
    , serviceCodes : List ServiceCode
    , consumers : List Consumer
    , dias : List DIA
    , fundingSources : List FundingSource
    , query : Maybe Query
    , pager : Pager
    }


type alias CountyData
    = ( List County, List City )


type UB     -- UnitsBlock
    = SelectServiceCode
    | SetUnits



init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , showModal = ( True, Modal.Spinner |> Just )
    , countyData = ( [], [] )
    , serviceCodes = []
    , consumers = []
    , dias = []
    , fundingSources = []
    , query = Search.Consumer.defaultQuery |> Just
    , pager = Data.Pager.new
    } ! [ Request.DIA.list url |> Http.send ( Dias >> Fetch )
    , Request.FundingSource.list url |> Http.send ( FundingSources >> Fetch )
    , Request.ServiceCode.list url |> Http.send ( ServiceCodes >> Fetch )
    , Request.County.list url |> Http.send ( Counties >> Fetch )
    , 0
        |> Request.Consumer.page url
            ( String.dropRight 5 << Dict.foldl fmtFuzzyMatch "" <| Search.Consumer.defaultQuery )
        |> Http.send ( Consumers >> Fetch )
    ]



-- UPDATE


type FetchedData
    = Cities ( Result Http.Error ( List City ) )
    | Consumers ( Result Http.Error ConsumerWithPager )
    | Counties ( Result Http.Error ( List County ) )
    | Dias ( Result Http.Error ( List DIA ) )
    | FundingSources ( Result Http.Error ( List FundingSource ) )
    | ServiceCodes ( Result Http.Error ( List ServiceCode ) )


type Msg
    = Add
    | AddUnitBlock Consumer
    | Cancel
    | ClearSearch
    | Delete Consumer
    | DeleteUnitBlock Consumer Int
    | Deleted ( Result Http.Error Int )
    | Edit Consumer
    | Fetch FetchedData
    | ModalMsg Modal.Msg
    | NewPage ( Maybe Int )
    | Post
    | Posted ( Result Http.Error Consumer )
    | Put
    | Putted ( Result Http.Error Consumer )
    | Search
    | Select Form.Selection Consumer String
    | SetCheckboxValue ( Bool -> Consumer ) Bool
    | SetFormValue ( String -> Consumer ) String
    | SetTableState Table.State
    | ShowUnits Consumer
    | UnitBlock UB Int String


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update url msg model =
    case msg of
        Add ->
            { model |
                action = Adding
                , disabled = True
                , editing = Nothing
                , errors = []
            } ! []

        AddUnitBlock editable ->
            let
                newEditable =
                    { editable |
                        serviceCodes =
                            editable.serviceCodes
                                |> List.reverse
                                >> (::) newServiceCode
                                >> List.reverse
                    }
            in
            { model |
                editing = newEditable |> Just
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
                    |> Request.Consumer.page url ""
                    |> Http.send ( Consumers >> Fetch )
                ]

        Delete consumer ->
            { model |
                editing = Just consumer
                , showModal = ( True , Nothing |> Modal.Delete Modal.Standard |> Just )
                , errors = []
            } ! []

        -- TODO: There should really only be one `Delete` Msg type which would then case switch on the type!
        DeleteUnitBlock consumer rownum ->
            { model |
--                editing = Just consumer
                showModal = ( True , rownum |> Just |> Modal.Delete Modal.UnitBlock |> Just )
                , errors = []
            } ! []

        Deleted ( Ok id ) ->
            { model |
                consumers = model.consumers |> List.filter ( \m -> id /= m.id )
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
            } ! []

        Edit consumer ->
            { model |
                action = Editing
                , disabled = True
                , editing = Just consumer
                , errors = []
            -- Fetch the county's zip codes to set the zip code drop-down to the correct value.
            } ! [ consumer.county |> toString |> Request.City.get url |> Http.send ( Cities >> Fetch ) ]

        Fetch result ->
            case result of
                Cities ( Ok cities ) ->
                    { model |
                        countyData = ( model.countyData |> Tuple.first, cities )
                        , tableState = Table.initialSort "ID"
                    } ! []

                Cities ( Err err ) ->
                    let
                        e =
                            case err of
                                Http.BadStatus e ->
                                    e.body

                                _ ->
                                    "nop"
                    in
                    { model |
                        countyData = ( model.countyData |> Tuple.first, [] )
                        , errors = (::) e model.errors
                        , tableState = Table.initialSort "ID"
                    } ! []

                Consumers ( Ok consumers ) ->
                    { model |
                        consumers = consumers.consumers
                        , pager = consumers.pager
                        , showModal = ( False, Nothing )
                        , tableState = Table.initialSort "ID"
                    } ! []

                Consumers ( Err err ) ->
                    let
                        e =
                            case err of
                                Http.BadStatus e ->
                                    e.body

                                _ ->
                                    "nop"
                    in
                    { model |
                        consumers = []
                        , errors = (::) e model.errors
                        , showModal = ( False, Nothing )
                        , tableState = Table.initialSort "ID"
                    } ! []

                Counties ( Ok counties ) ->
                    { model |
                        countyData = ( counties, model.countyData |> Tuple.second )
                        , tableState = Table.initialSort "ID"
                    } ! []

                Counties ( Err err ) ->
                    let
                        e =
                            case err of
                                Http.BadStatus e ->
                                    e.body

                                _ ->
                                    "nop"
                    in
                    { model |
                        countyData = ( [], model.countyData |> Tuple.second )
                        , errors = (::) e model.errors
                        , tableState = Table.initialSort "ID"
                    } ! []

                Dias ( Ok dias ) ->
                    { model |
                        dias = dias
                        , tableState = Table.initialSort "ID"
                    } ! []

                Dias ( Err err ) ->
                    let
                        e =
                            case err of
                                Http.BadStatus e ->
                                    e.body

                                _ ->
                                    "nop"
                    in
                    { model |
                        dias = []
                        , errors = (::) e model.errors
                        , tableState = Table.initialSort "ID"
                    } ! []

                FundingSources ( Ok fundingSources ) ->
                    { model |
                        fundingSources = fundingSources
                        , tableState = Table.initialSort "ID"
                    } ! []

                FundingSources ( Err err ) ->
                    let
                        e =
                            case err of
                                Http.BadStatus e ->
                                    e.body

                                _ ->
                                    "nop"
                    in
                    { model |
                        fundingSources = []
                        , errors = (::) e model.errors
                        , tableState = Table.initialSort "ID"
                    } ! []

                ServiceCodes ( Ok serviceCodes ) ->
                    { model |
                        serviceCodes = serviceCodes
                        , tableState = Table.initialSort "ID"
                    } ! []

                ServiceCodes ( Err err ) ->
                    let
                        e =
                            case err of
                                Http.BadStatus e ->
                                    e.body

                                _ ->
                                    "nop"
                    in
                    { model |
                        serviceCodes = []
                        , errors = (::) e model.errors
                        , tableState = Table.initialSort "ID"
                    } ! []

        ModalMsg subMsg ->
            let
                pattern =
                    model.showModal
                        |> Tuple.second
                        |> Maybe.withDefault ( Modal.Delete Modal.Standard Nothing )

                ( showModal, whichModal, query, editing, cmd ) =
                    case ( subMsg |> Modal.update model.query, pattern ) of
                        {- Delete Modal

                             Matches:
                                  ( ( Bool, Maybe Query ),
                                      Modal.Delete Modal.DeleteType ( Maybe Int )
                                  )
                        -}
                        ( ( False, Nothing ),
                            Modal.Delete Modal.Standard Nothing
                        ) ->
                            ( False
                            , Nothing
                            , model.query
                            , model.editing
                            , Cmd.none
                            )

                        ( ( True, Nothing ),
                            Modal.Delete Modal.Standard Nothing
                        ) ->
                            ( False
                            , Nothing
                            , model.query
                            , model.editing
                            , Maybe.withDefault new model.editing
                                |> Request.Consumer.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
                            )

                        ( ( False, Nothing ),
                            Modal.Delete Modal.UnitBlock ( Just rownum )
                        ) ->
                            ( False
                            , Nothing
                            , model.query
                            , model.editing
                            , Cmd.none
                            )

                        ( ( True, Nothing ),
                            Modal.Delete Modal.UnitBlock ( Just rownum )
                        ) ->
                            let
                                oldEditing =
                                    model.editing
                                        |> Maybe.withDefault new

                                serviceCodes =
                                    oldEditing.serviceCodes

                                last =
                                    1 |> (-) ( serviceCodes |> List.length )

                                markForDeletion oldServiceCode =
                                    Data.Consumer.ServiceCode
                                        -- Flip bits doing bitwise NOT (aka two's complement) and do the same operation
                                        -- if the edit is canceled.
                                        -- Note that this is fine b/c no unit block in the database will have an id of 0
                                        -- (i.e., there will be no confusion when a new service code is added on the UI,
                                        -- which gets an id of -1 (note that ~0 == -1)).
                                        ( oldServiceCode.id |> Bitwise.complement )
                                        oldServiceCode.serviceCode
                                        oldServiceCode.units

                                makeServiceCode serviceCodes =
                                    serviceCodes
                                        |> List.head
                                        >> Maybe.withDefault newServiceCode
                                        -- If id == -1, it's new (server has no knowledge of it) so return an empty array. This effectively
                                        -- prunes the serviceCode from the list.
                                        >> ( \serviceCode ->
                                            if (==) -1 serviceCode.id
                                            then []
                                            else [ serviceCode |> markForDeletion ]
                                            )

                                newServiceCodes =
                                    if (==) 0 rownum then
                                        -- Replace the head element with a new Service Code and join back together.
                                        List.tail serviceCodes
                                            |> Maybe.withDefault []
                                            |> (++) ( serviceCodes |> makeServiceCode )
                                    else if (==) last rownum then
                                        -- Replace the last element with a new Service Code and join back together after having initially reversed the list.
                                        serviceCodes
                                            |> List.reverse
                                            >> List.drop 1      -- This is the list element that will be replaced.
                                            >> (++) (
                                                serviceCodes
                                                    |> List.reverse
                                                    >> makeServiceCode
                                                )
                                            >> List.reverse
                                    else
                                        -- 1. Drop everything up to and including the selected element.
                                        -- 2. Make new service code and add it to the front of the tail elements from step #1.
                                        -- 3. Take all elements from the head of the list up to the selected element and append the new list from steps #2 and #3.
                                        serviceCodes
                                            |> List.drop ( (+) rownum 1 )
                                            >> (++) (
                                                serviceCodes
                                                    |> List.drop rownum
                                                    >> makeServiceCode
                                                )
                                            >> (++) (
                                                serviceCodes
                                                    |> List.take rownum
                                                )
                            in
                            ( False
                            , Nothing
                            , model.query
                            , { oldEditing | serviceCodes = newServiceCodes } |> Just
                            , Cmd.none
                            )

                        {- Search Modal

                             Matches:
                                  ( ( Bool, Maybe Query ),
                                      Modal.Search Modal.SearchType ( Maybe User ) ( Maybe Query ) ( Maybe ViewLists )
                                  )
                        -}
                        ( ( False, Just query ), _ ) ->
                            let
                                q =
                                    String.dropRight 5   -- Remove the trailing " AND ".
                                        <<  Dict.foldl fmtFuzzyMatch ""
                                        <| query
                            in
                            ( True
                            , Modal.Spinner |> Just
                            , query |> Just
                            , model.editing
                            , Request.Consumer.page url q 0
                                |> Http.send ( Consumers >> Fetch )
                            )

                        ( ( True, Just query ), _ ) ->
                            ( True
                            , Nothing
                                |> Modal.Search Data.Search.Consumer Nothing model.query
                                |> Just
                            , query |> Just
                            , model.editing
                            , Cmd.none
                            )

                        ( _, _ ) ->
                            ( False
                            , Nothing
                            , model.query
                            , model.editing
                            , Cmd.none
                            )
            in
            { model |
                -- This only applies to Modal.UnitBlock delete modal. If objects don't equal than a unit block has been deleted.
                disabled = (==) editing model.editing
                , editing = editing
                , query = query
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
                |> Request.Consumer.page url s
                |> Http.send ( Consumers >> Fetch )
            ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just consumer ->
                            Validate.Consumer.errors consumer

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just consumer ->
                            Request.Consumer.post url consumer
                                |> Http.toTask
                                |> Task.attempt Posted
                    else
                        Cmd.none
            in
                { model |
                    disabled = True
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
                                |> List.sortBy .lastname
            in
            { model |
                action = None
                , consumers = consumers
                , editing = Nothing
                , errors = []
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
                    case model.editing of
                        Nothing ->
                            []

                        Just consumer ->
                            Validate.Consumer.errors consumer

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just consumer ->
                            Request.Consumer.put url consumer
                                |> Http.toTask
                                |> Task.attempt Putted
                    else
                        Cmd.none
            in
            { model |
                disabled = True
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
                                -- Keep sort order.
                                |> List.map ( \m ->
                                        if consumer.id /= m.id
                                        then m
                                        else { newConsumer | id = consumer.id }
                                    )
            in
                { model |
                    action = None
                    , consumers = consumers
                    , editing = Nothing
                    , errors = []
                -- TODO
                -- Note that we need to redownload the consumers with each successful update b/c new service code (blocks) can/may have been added!
                -- The service codes come down with the consumers.  This will probably become untenable since we're fetching everything when we really
                -- just want the service codes (recall that a new service code will have an id of -1, and it's less expensive to send the new service
                -- codes than to loop over the client-side cache of service codes and update the new service code.
                } ! [
                        0
                            |> Request.Consumer.page
                                url
                                (
                                    model.query
                                        |> Maybe.withDefault Dict.empty
                                        |> Dict.foldl fmtFuzzyMatch ""
                                        |> String.dropRight 5   -- Remove the trailing " AND ".
                                )
                            |> Http.send ( Consumers >> Fetch )
                    ]

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

        Search ->
            { model |
                showModal = ( True , Nothing |> Modal.Search Data.Search.Consumer Nothing model.query |> Just )
                , errors = []
            } ! []

        Select selectType consumer selectionString ->
            let
                selectionToInt =
                    selectionString |> Form.toInt

                newModel a =
                    { model |
                        editing = a |> Just
                        , disabled = False
                    }
            in
            case selectType of
                Form.CountyID ->
                    ( { consumer | county = selectionToInt } |> newModel ) ! [
                        selectionString |> Request.City.get url |> Http.send ( Cities >> Fetch )
                    ]

                Form.DIAID ->
                    ( { consumer | dia = selectionToInt } |> newModel ) ! []

                Form.FundingSourceID ->
                    ( { consumer | fundingSource = selectionToInt } |> newModel ) ! []

                Form.ZipID ->
                    ( { consumer | zip = selectionString } |> newModel ) ! []

                _ ->
                    model ! []

        -- TODO: This could be DRYed out!
        UnitBlock unitBlockType id inputString ->
            let
                oldEditing =
                    model.editing
                        |> Maybe.withDefault new

                serviceCodes =
                    oldEditing.serviceCodes

                last =
                    1 |> (-) ( serviceCodes |> List.length )

                makeServiceCode fn serviceCodes =
                    serviceCodes
                        |> List.head
                        >> Maybe.withDefault newServiceCode
                        >> fn

                newServiceCodes fn =
                    if (==) id 0 then
                        -- Replace the head element with a new Service Code and join back together.
                        List.tail serviceCodes
                            |> Maybe.withDefault []
                            |> (::) ( serviceCodes |> makeServiceCode fn )
                    else if (==) id last then
                        -- Replace the last element with a new Service Code and join back together after having initially reversed the list.
                        serviceCodes
                            |> List.reverse
                            >> List.drop 1      -- This is the list element that will be replaced.
                            >> (::) (
                                serviceCodes
                                    |> List.reverse
                                    >> makeServiceCode fn
                                )
                            >> List.reverse
                    else
                        -- 1. Drop everything up to and including the selected element.
                        -- 2. Make new service code and add it to the front of the tail elements from step #1.
                        -- 3. Take all elements from the head of the list up to the selected element and append the new list from steps #2 and #3.
                        serviceCodes
                            |> List.drop ( (+) id 1 )
                            >> (::) (
                                serviceCodes
                                    |> List.drop id
                                    >> makeServiceCode fn
                                )
                            >> (++) (
                                serviceCodes
                                    |> List.take id
                                )
            in
            case unitBlockType of
                SelectServiceCode ->
                    let
                        selectionToInt =
                            inputString |> Form.toInt

                        getNewServiceCode oldServiceCode =
                            Data.Consumer.ServiceCode oldServiceCode.id selectionToInt oldServiceCode.units
                    in
                    { model |
                        disabled = False
                        , editing = { oldEditing | serviceCodes = getNewServiceCode |> newServiceCodes } |> Just
                    } ! []

                SetUnits ->
                    let
                        unitsToFloat =
                            inputString |> Form.toFloat

                        getNewServiceCode oldServiceCode =
                            Data.Consumer.ServiceCode oldServiceCode.id oldServiceCode.serviceCode unitsToFloat
                    in
                    { model |
                        disabled = False
                        , editing = { oldEditing | serviceCodes = getNewServiceCode |> newServiceCodes } |> Just
                    } ! []

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

        ShowUnits consumer ->
--            let
--                subCmd =
--                    Request.PayHistory.list url specialist.id
--                        |> Http.toTask
--                        |> Task.attempt ShowPayHistoryList
--            in
            { model |
                action = Views.Page.Units consumer
            } ! []



-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (++)
            [ h1 [] [ "Consumer" |> pageTitle model.action |> text ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView model =
    let
        showList =
            case model.consumers |> List.length of
                0 ->
                    div [] []
                _ ->
                    model.consumers
                        |> Table.view ( model |> config ) model.tableState

        showPager =
            model.pager |> Views.Pager.view NewPage

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
                [ button [ Add |> onClick ] [ text "Add Consumer" ]
                , button [ Search |> onClick ] [ text "Search" ]
                , button [ hideClearTextButton |> hidden, ClearSearch |> onClick ] [ text "Clear Search" ]
                ]
            , showPager
            , showList
            , showPager
            , model.showModal
                |> Modal.view Nothing model.query
                |> Html.map ModalMsg
            ]

        Adding ->
            [ form [ onSubmit Post ]
                ( (++)
                    ( ( model.editing, model.serviceCodes, model.dias, model.fundingSources, model.countyData ) |> formRows )
                    [ Form.submit model.disabled Cancel ]
                )
            , model.showModal
                |> Modal.view Nothing model.query
                |> Html.map ModalMsg
            ]

        Editing ->
            [ form [ onSubmit Put ]
                ( (++)
                    ( ( model.editing, model.serviceCodes, model.dias, model.fundingSources, model.countyData ) |> formRows )
                    [ Form.submit model.disabled Cancel ]
                )
            , model.showModal
                |> Modal.view Nothing model.query
                |> Html.map ModalMsg
            ]

        Units consumer ->
            [ div [] []
                , Form.submit True Cancel

            ]

        _ ->
            [ div [] []
            ]


unitsBlock : List ServiceCode -> Consumer -> List ( Html Msg )
unitsBlock fetchedServiceCodes consumer =
    let
        -- Remember that new service codes are designated as having an id of -1, so
        -- we need to check for id that are less than that.
        --
        -- Since extant service codes are marked for deletion by bitwise NOTing its
        -- id, the highest "marked for deletion" id will be -2 (~1 == -2, since the
        -- db ids start at 1).
        shouldHide serviceCode =
            if (<) serviceCode.id -1
            then True
            else False
    in
    consumer.serviceCodes
        |> List.indexedMap ( \index serviceCode -> div [ "unitBlock" |> class, serviceCode |> shouldHide >> hidden ]
                [ Form.select "Service Code"
                    [ id "serviceCodeSelection"
                    , index |> UnitBlock SelectServiceCode |> onInput
                    ] (
                        fetchedServiceCodes
                            |> List.map ( \m -> ( m.id |> toString, m.name ) )
                            |> (::) ( "-1", "-- Select a Service code --" )
                            |> List.map ( serviceCode.serviceCode |> toString |> Form.option )
                    )
                , Form.float "Units"
                    [ serviceCode.units |> toString |> value
                    , index |> UnitBlock SetUnits |> onInput
                    ]
                    []
                -- Specify type "button" in a form or the button will assume the default behavior and submit the form when clicked!
                , button [ "button" |> type_, index |> DeleteUnitBlock consumer |> onClick ] [ "X" |> text ]
                ]
            )


formRows : ( Maybe Consumer, List ServiceCode, List DIA, List FundingSource, CountyData ) -> List ( Html Msg )
formRows ( editing, serviceCodes, dias, fundingSources, countyData ) =
    let
        editable =
            editing |> Maybe.withDefault new
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
                |> (::) ( "-1", "-- Select a County --" )
                |> List.map ( editable.county |> toString |> Form.option )
        )
    , div [ "unitsBlock" |> id ] (
         editable |> unitsBlock serviceCodes
             |> (::) ( input [ editable |> AddUnitBlock |> onClick, type_ "button", value "Add Service Code" ] [] )
    )
    , Form.select "Funding Source"
        [ id "fundingSourceSelection"
        , editable |> Select Form.FundingSourceID |> onInput
        ] (
            fundingSources
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a Funding Source --" )
                |> List.map ( editable.fundingSource |> toString |> Form.option )
        )
    , Form.text "Zip code"
        [ value editable.zip
        , onInput ( SetFormValue (\v -> { editable | zip = v } ) )
        ]
        []
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
    , Form.select "DIA"
        [ id "diaSelection"
        , editable |> Select Form.DIAID |> onInput
        ] (
            dias
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a DIA --" )
                |> List.map ( editable.dia |> toString |> Form.option )
        )
    , Form.textarea "Other"
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
        [ Table.stringColumn "Full Name" ( \m ->        -- "Cricket, Rickety"
            (++)
                m.lastname
                ( (++)
                    ( ", ")
                    m.firstname
                )
        )
        , Table.stringColumn "First Name" .firstname
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
        , Table.stringColumn "Funding Source" (
            .fundingSource
                >> ( \id ->
                    model.fundingSources |> List.filter ( \m -> m.id |> (==) id )
                    )
                >> List.head
                >> Maybe.withDefault { id = -1, name = "" }
                >> .name
        )
        , Table.stringColumn "Zip Code" .zip
        , Table.stringColumn "BSU" .bsu
        , Table.stringColumn "Recipient ID" .recipientID
        , Table.stringColumn "DIA" (
            .dia
                >> ( \id ->
                    model.dias |> List.filter ( \m -> m.id |> (==) id )
                    )
                >> List.head
                >> Maybe.withDefault { id = -1, name = "" }
                >> .name
        )
        , Table.floatColumn "Total Units" (
            List.foldl
                ( \serviceCode acc ->
                    serviceCode.units |> (+) acc
                )
                0.0
            << .serviceCodes
        )
        , Table.stringColumn "Other" .other
        , customColumn ( viewButton Edit "Edit" ) ""
        , customColumn ( viewButton Delete "Delete" ) ""
--        , customColumn ( viewButton ShowUnits "Service Codes and Units" ) ""
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
    [ input [ checked active, Html.Attributes.disabled True, type_ "checkbox" ] []
    ]


