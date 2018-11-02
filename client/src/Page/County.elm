module Page.County exposing (Model, Msg, init, update, view)

import Data.County exposing (County, CountyWithPager, new)
import Data.Pager exposing (Pager)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, span, text)
import Html.Attributes exposing (action, autofocus, checked, class, for, id, style, type_, value)
import Html.Events exposing (onCheck, onClick, onInput, onSubmit)
import Http
import Request.County
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Validate.County
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
    , editing : Maybe County
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , counties : List County
    , pager : Pager
    }



init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , showModal = ( True, Modal.Spinner |> Just )
    , counties = []
    , pager = Data.Pager.new
    } ! [ 0
        |> Request.County.page url |> Http.send ( Counties >> Fetch )
    ]


-- UPDATE


type FetchedData
    = Counties ( Result Http.Error CountyWithPager )


type Msg
    = Add
    | Cancel
    | Delete County
    | Deleted ( Result Http.Error Int )
    | Edit County
    | Fetch FetchedData
    | ModalMsg Modal.Msg
    | NewPage ( Maybe Int )
    | Post
    | Posted ( Result Http.Error County )
    | Put
    | Putted ( Result Http.Error County )
    | SelectCounty County String
    | SetFormValue ( String -> County ) String
    | SetTableState Table.State


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update url msg model =
    case msg of
        Add ->
            { model |
                action = Adding
                , disabled = True
                , errors = []
                , editing = Nothing
            } ! []

        Cancel ->
            { model |
                action = None
                , editing = Nothing
                , errors = []
            } ! []

        Delete county ->
            { model |
                editing = Just county
                , showModal = ( True , Nothing |> Modal.Delete Modal.Standard |> Just )
                , errors = []
            } ! []

        Deleted ( Ok id ) ->
            { model |
                counties = model.counties |> List.filter ( \m -> id /= m.id )
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

        Edit county ->
            { model |
                action = Editing
                , disabled = True
                , editing = Just county
                , errors = []
            } ! []

        Fetch result ->
            case result of
                Counties ( Ok counties ) ->
                    { model |
                        counties = counties.counties
                        , showModal = ( False, Nothing )
                        , pager = counties.pager
                        , tableState = Table.initialSort "ID"
                    } ! []

                Counties ( Err err ) ->
                    let
                        er = (Debug.log "err" err)
                        e =
                            case err of
                                Http.BadStatus e ->
                                    e.body

                                _ ->
                                    "nop"
                    in
                    { model |
                        counties = []
                        , showModal = ( False, Nothing )
                        , tableState = Table.initialSort "ID"
                        , errors = (::) e model.errors
                    } ! []

        ModalMsg subMsg ->
            let
                cmd =
                    case subMsg |> Modal.update Nothing of
                        ( False, _ ) ->
                            Cmd.none

                        ( True, _ ) ->
                            Maybe.withDefault new model.editing
                                |> Request.County.delete url
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
                |> Request.County.page url
                |> Http.send ( Counties >> Fetch )
            ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just county ->
                            Validate.County.errors county

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just county ->
                            Request.County.post url county
                                |> Http.toTask
                                |> Task.attempt Posted
                    else
                        Cmd.none
            in
            { model |
                disabled = True
                , errors = errors
            } ! [ subCmd ]

        Posted ( Ok county ) ->
            let
                counties =
                    case model.editing of
                        Nothing ->
                            model.counties

                        Just newCounty ->
                            model.counties
                                |> (::) { newCounty | id = county.id }
                                |> List.sortBy .name
            in
            { model |
                action = None
                , counties = counties
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

                        Just county ->
                            Validate.County.errors county

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just county ->
                            Request.County.put url county
                                |> Http.toTask
                                |> Task.attempt Putted
                    else
                        Cmd.none
            in
            { model |
                disabled = True
                , errors = errors
            } ! [ subCmd ]

        Putted ( Ok county ) ->
            let
                counties =
                    case model.editing of
                        Nothing ->
                            model.counties

                        Just newCounty ->
                            model.counties
                                |> List.map ( \m ->
                                        if county.id /= m.id
                                        then m
                                        else { newCounty | id = county.id }
                                    )
            in
            { model |
                action = None
                , counties = counties
                , editing = Nothing
                , errors = []
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

        SelectCounty county countyID ->
            { model |
                editing = { county | id = countyID |> Form.toInt } |> Just
                , disabled = False
            } ! []

        SetFormValue setFormValue s ->
            { model |
                editing = setFormValue s |> Just
                , disabled = False
            } ! []

        SetTableState newState ->
            { model | tableState = newState } ! []



-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (++)
            [ h1 [] [ "Counties" |> pageTitle model.action |> text ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView (
    { action
    , counties
    , disabled
    , editing
    , tableState
    } as model ) =
    let
        editable : County
        editable = case editing of
            Nothing ->
                new

            Just county ->
                county

        showList : Html Msg
        showList =
            case counties |> List.length of
                0 ->
                    div [] []
                _ ->
                    counties
                    |> Table.view ( model |> config ) tableState

        showPager =
            model.pager |> Views.Pager.view NewPage
    in
    case action of
        None ->
            [ div [ "buttons" |> class ]
                [ button [ onClick Add ] [ text "Add County" ]
                ]
            , showPager
            , showList
            , showPager
            , model.showModal
                |> Modal.view Nothing Nothing
                |> Html.map ModalMsg
            ]

        Adding ->
            [ form [ onSubmit Post ]
                ( (++)
                    ( ( editable, counties ) |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]

        Editing ->
            [ form [ onSubmit Put ]
                ( (++)
                    ( ( editable, counties ) |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]

        _ ->
            [ div [] [] ]


formRows : ( County, List County ) -> List ( Html Msg )
formRows ( editable, counties ) =
    [ Form.select "County"
        [ id "countieselection"
        , editable |> SelectCounty |> onInput
        ] (
            counties
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a County --" )
                |> List.map ( editable.id |> toString |> Form.option )
        )
    ]

-- TABLE CONFIGURATION


config : Model -> Table.Config County Msg
config model =
    Table.customConfig
    { toId = .id >> toString
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "County" (
            .id
                >> ( \id ->
                    model.counties |> List.filter ( \m -> m.id |> (==) id )
                    )
                >> List.head
                >> Maybe.withDefault Data.County.new
                >> .name
        )
        , customColumn ( viewButton Edit "Edit" ) ""
        , customColumn ( viewButton Delete "Delete" ) ""
        ]
    , customizations = defaultCustomizations
    }


customColumn : ( County -> Table.HtmlDetails Msg ) -> String -> Table.Column County Msg
customColumn viewElement header =
    Table.veryCustomColumn
        { name = header
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( County -> msg ) -> String -> ( County -> Table.HtmlDetails msg )
viewButton msg name county =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| county ] [ text name ]
        ]


