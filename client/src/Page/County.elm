module Page.County exposing (Model, Msg, init, update, view)

import Data.City exposing (City, CityWithPager, new)
import Data.County exposing (County)
import Data.Pager exposing (Pager)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, span, text)
import Html.Attributes exposing (action, autofocus, checked, class, for, id, style, type_, value)
import Html.Events exposing (onCheck, onClick, onInput, onSubmit)
import Http
import Request.City
import Request.County
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Validate.City
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
    , editing : Maybe City
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , cities : List City
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
    , cities = []
    , counties = []
    , pager = Data.Pager.new
    } ! [ Request.County.list url |> Http.send ( Counties >> Fetch )
    , 0 |> Request.City.page url |> Http.send ( Cities >> Fetch )
    ]


-- UPDATE


type FetchedData
    = Cities ( Result Http.Error CityWithPager )
    | Counties ( Result Http.Error ( List County ) )


type Msg
    = Add
    | Cancel
    | Delete City
    | Deleted ( Result Http.Error Int )
    | Edit City
    | Fetch FetchedData
    | ModalMsg Modal.Msg
    | NewPage ( Maybe Int )
    | Post
    | Posted ( Result Http.Error City )
    | Put
    | Putted ( Result Http.Error City )
    | SelectCounty City String
    | SetFormValue ( String -> City ) String
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

        Delete city ->
            { model |
                editing = Just city
                , showModal = ( True , Nothing |> Modal.Delete Modal.Standard |> Just )
                , errors = []
            } ! []

        Deleted ( Ok id ) ->
            { model |
                cities = model.cities |> List.filter ( \m -> id /= m.id )
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
                Cities ( Ok cities ) ->
                    { model |
                        cities = cities.cities
                        , showModal = ( False, Nothing )
                        , pager = cities.pager
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
                        cities = []
                        , showModal = ( False, Nothing )
                        , tableState = Table.initialSort "ID"
                        , errors = (::) e model.errors
                    } ! []

                Counties ( Ok counties ) ->
                    { model |
                        counties = counties
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
                        tableState = Table.initialSort "ID"
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
                                |> Request.City.delete url
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
                |> Request.City.page url
                |> Http.send ( Cities >> Fetch )
            ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just city ->
                            Validate.City.errors city

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just city ->
                            Request.City.post url city
                                |> Http.toTask
                                |> Task.attempt Posted
                    else
                        Cmd.none
            in
            { model |
                disabled = True
                , errors = errors
            } ! [ subCmd ]

        Posted ( Ok city ) ->
            let
                cities =
                    case model.editing of
                        Nothing ->
                            model.cities

                        Just newCity ->
                            model.cities
                                |> (::) { newCity | id = city.id }
                                |> List.sortBy .name
            in
            { model |
                action = None
                , cities = cities
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

                        Just city ->
                            Validate.City.errors city

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just city ->
                            Request.City.put url city
                                |> Http.toTask
                                |> Task.attempt Putted
                    else
                        Cmd.none
            in
            { model |
                disabled = True
                , errors = errors
            } ! [ subCmd ]

        Putted ( Ok city ) ->
            let
                cities =
                    case model.editing of
                        Nothing ->
                            model.cities

                        Just newCity ->
                            model.cities
                                |> List.map ( \m ->
                                        if city.id /= m.id
                                        then m
                                        else { newCity | id = city.id }
                                    )
            in
            { model |
                action = None
                , cities = cities
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

        SelectCounty city countyID ->
            { model |
                editing = { city | county = countyID |> Form.toInt } |> Just
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
            [ h1 [] [ "Cities / Counties" |> pageTitle model.action |> text ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView (
    { action
    , cities
    , disabled
    , editing
    , tableState
    , counties
    } as model ) =
    let
        editable : City
        editable = case editing of
            Nothing ->
                new

            Just city ->
                city

        showList : Html Msg
        showList =
            case cities |> List.length of
                0 ->
                    div [] []
                _ ->
                    cities
                    |> Table.view ( model |> config ) tableState

        showPager =
            model.pager |> Views.Pager.view NewPage
    in
    case action of
        None ->
            [ div [ "buttons" |> class ]
                [ button [ onClick Add ] [ text "Add City" ]
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


formRows : ( City, List County ) -> List ( Html Msg )
formRows ( editable, counties ) =
    [ Form.text "City"
        [ value editable.name
        , onInput ( SetFormValue ( \v -> { editable | name = v } ) )
        ]
        []
    , Form.text "State"
        [ value editable.state
        , onInput ( SetFormValue ( \v -> { editable | state = v } ) )
        ]
        []
    , Form.text "Zip Code"
        [ value editable.zip
        , onInput ( SetFormValue ( \v -> { editable | zip = v } ) )
        ]
        []
    , Form.select "County"
        [ id "countieselection"
        , editable |> SelectCounty |> onInput
        ] (
            counties
                |> List.map ( \m -> ( m.id |> toString, m.name ) )
                |> (::) ( "-1", "-- Select a County --" )
                |> List.map ( editable.county |> toString |> Form.option )
        )
    ]

-- TABLE CONFIGURATION


config : Model -> Table.Config City Msg
config model =
    Table.customConfig
    { toId = .id >> toString
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "City" .name
        , Table.stringColumn "State" .state
        , Table.stringColumn "Zip Code" .zip
        , Table.stringColumn "County" (
            .county
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


customColumn : ( City -> Table.HtmlDetails Msg ) -> String -> Table.Column City Msg
customColumn viewElement header =
    Table.veryCustomColumn
        { name = header
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( City -> msg ) -> String -> ( City -> Table.HtmlDetails msg )
viewButton msg name city =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| city ] [ text name ]
        ]


