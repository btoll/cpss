module Page.County exposing (Model, Msg, init, update, view)

import Data.City exposing (City, Cities, new)
import Data.County exposing (County)
import Data.Pager exposing (Pager)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, node, section, span, text)
import Html.Attributes exposing (action, autofocus, checked, for, id, style, type_, value)
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



-- MODEL

type alias Model =
    { errors : List ( Validate.City.Field, String )
    , tableState : Table.State
    , action : Action
    , editing : Maybe City
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , cities : List City
    , counties : List County
    , pager : Pager
    }


type Action = None | Adding | Editing



init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , showModal = ( False, Nothing )
    , cities = []
    , counties = []
    , pager =
        { currentPage = 0
        , recordsPerPage = 0
        , totalCount = 0
        }
    } ! [ Request.County.list url |> Http.send FetchedCounties
    , 0 |> Request.City.list url |> Http.send FetchedCities
    ]


-- UPDATE


type Msg
    = Add
    | Cancel
    | Delete City
    | Deleted ( Result Http.Error Int )
    | Edit City
    | FetchedCities ( Result Http.Error Cities )
    | FetchedCounties ( Result Http.Error ( List County ) )
    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error City )
    | Put
    | Putted ( Result Http.Error City )
    | SelectCounty City String
    | SetFormValue ( String -> City ) String
    | SetTableState Table.State
    | Submit

    | Next
    | Prev


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

        Delete city ->
            { model |
                editing = Just city
                , showModal = ( True , Modal.Delete |> Just )
            } ! []

        Deleted ( Ok id ) ->
            { model |
                cities = model.cities |> List.filter ( \m -> id /= m.id )
            } ! []

        Deleted ( Err err ) ->
            { model |
                action = None
--                , errors = (::) "There was a problem, the record could not be deleted!" model.errors
            } ! []

        Edit county ->
            { model |
                action = Editing
                , editing = Just county
            } ! []

        FetchedCities ( Ok cities ) ->
            { model |
                cities = cities.cities
                , pager = cities.pager
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedCities ( Err err ) ->
            { model |
                cities = []
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedCounties ( Ok counties ) ->
            { model |
                counties = counties
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedCounties ( Err err ) ->
            { model |
                tableState = Table.initialSort "ID"
            } ! []

        ModalMsg subMsg ->
            let
                cmd =
                    case ( subMsg |> Modal.update ) of
                        False ->
                            Cmd.none

                        True ->
                            Maybe.withDefault new model.editing
                                |> Request.City.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
            in
            { model |
                showModal = ( False, Nothing )
            } ! [ cmd ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just city ->
                            Validate.City.errors city

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just city ->
                            ( None
                            , Request.City.post url city
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

        Posted ( Ok city ) ->
            let
                cities =
                    case model.editing of
                        Nothing ->
                            model.cities

                        Just newCity ->
                            model.cities
                                |> (::) { newCity | id = city.id }
            in
            { model |
                cities = cities
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

                        Just city ->
                            Validate.City.errors city

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just city ->
                            ( None
                            , Request.City.put url city
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

        Putted ( Ok city ) ->
            let
                cities =
                    case model.editing of
                        Nothing ->
                            model.cities

                        Just newCity ->
                            model.cities
                                |> List.filter ( \m -> city.id /= m.id )
                                |> (::) { newCity | id = city.id }
            in
                { model |
                    cities = cities
                    , editing = Nothing
                } ! []

        Putted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be updated!" model.errors
            } ! []

        SelectCounty city countyID ->
            { model |
                editing = { city | countyID = countyID |> Form.toInt } |> Just
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

        Submit ->
            { model |
                action = None
                , disabled = True
            } ! []

        Next ->
            model !
            [ 1
                |> (+) model.pager.currentPage
                |> Request.City.list url
                |> Http.send FetchedCities
            ]

        Prev ->
            model !
            [ 1
                |> (-) model.pager.currentPage
                |> Request.City.list url
                |> Http.send FetchedCities
            ]



-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (++)
            [ h1 [] [ text "Cities / Counties" ]
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

        showList =
            case cities |> List.length of
                0 ->
                    div [] []
                _ ->
                    cities
                    |> Table.view config tableState

        isPrevDisabled =
            (==) model.pager.currentPage 0

--        isNextDisabled =
--            model.pager.currentPage
--                |> (>) 0
    in
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add City" ]

            , button [ Html.Attributes.disabled isPrevDisabled, onClick Prev ] [ text "Prev" ]
            , span [] [ 1 |> (+) model.pager.currentPage |> toString |> text ]
            , button [ Html.Attributes.disabled False, onClick Next ] [ text "Next" ]

            , showList

            , button [ Html.Attributes.disabled isPrevDisabled, onClick Prev ] [ text "Prev" ]
            , span [] [ 1 |> (+) model.pager.currentPage |> toString |> text ]
            , button [ Html.Attributes.disabled False, onClick Next ] [ text "Next" ]

            , model.showModal
                |> Modal.view
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
                |> (::) ( "-1", "-- Select a county --" )
                |> List.map ( editable.countyID |> toString |> Form.option )
        )
    ]

-- TABLE CONFIGURATION


config : Table.Config City Msg
config =
    Table.customConfig
    { toId = .id >> toString
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "City" .name
        , Table.stringColumn "State" .state
        , Table.stringColumn "Zip Code" .zip
        , Table.intColumn "County" .countyID
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


