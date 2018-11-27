module Page.DIA exposing (Model, Msg, init, update, view)

import Data.DIA as DIA exposing (DIA, new)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, class, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.DIA
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Validate.DIA
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal
import Views.Page exposing (ViewAction(..), pageTitle)



-- MODEL


type alias Model =
    { errors : List String
    , tableState : Table.State
    , action : ViewAction
    , editing : Maybe DIA
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , dias : List DIA
    }



init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , showModal = ( True, Modal.Spinner |> Just )
    , dias = []
    } ! [ Request.DIA.list url |> Http.send FetchedDIA ]



-- UPDATE


type Msg
    = Add
    | Cancel
    | Delete DIA
    | Deleted ( Result Http.Error DIA )
    | Edit DIA
    | FetchedDIA ( Result Http.Error ( List DIA ) )
    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error DIA )
    | Put
    | Putted ( Result Http.Error DIA )
    | SetFormValue ( String -> DIA ) String
    | SetTableState Table.State


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

        Cancel ->
            { model |
                action = None
                , editing = Nothing
                , errors = []
            } ! []

        Delete dia ->
            { model |
                editing = Just dia
                , showModal = ( True , Nothing |> Modal.Delete Modal.Standard |> Just )
                , errors = []
            } ! []

        Deleted ( Ok dia ) ->
            { model |
                dias = model.dias |> List.filter ( \m -> dia.id /= m.id )
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
                errors = (::) e model.errors
            } ! []

        Edit dia ->
            { model |
                action = Editing
                , disabled = True
                , editing = Just dia
                , errors = []
            } ! []

        FetchedDIA ( Ok dias ) ->
            { model |
                dias = dias
                , showModal = ( False, Nothing )
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedDIA ( Err err ) ->
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
                                |> Request.DIA.delete url
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

                        Just dia ->
                            Validate.DIA.errors dia

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just dia ->
                            Request.DIA.post url dia
                                |> Http.toTask
                                |> Task.attempt Posted
                    else
                        Cmd.none
            in
                { model |
                    disabled = True
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok dia ) ->
            let
                d =
                    case model.editing of
                        Nothing ->
                            model.dias

                        Just newDIA ->
                            model.dias
                                |> (::) { newDIA | id = dia.id }
                                |> List.sortBy .name
            in
                { model |
                    action = None
                    , dias = d
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

                        Just dia ->
                            Validate.DIA.errors dia

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just dia ->
                            Request.DIA.put url dia
                                |> Http.toTask
                                |> Task.attempt Putted
                    else
                        Cmd.none
            in
                { model |
                    disabled = True
                    , errors = errors
                } ! [ subCmd ]

        Putted ( Ok dia ) ->
            let
                dias =
                    case model.editing of
                        Nothing ->
                            model.dias

                        Just newDIA ->
                            model.dias
                                |> List.map ( \m ->
                                        if dia.id /= m.id
                                        then m
                                        else { newDIA | id = dia.id }
                                    )
            in
                { model |
                    action = None
                    , dias = dias
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

        SetTableState newState ->
            { model | tableState = newState
            } ! []

        SetFormValue setFormValue s ->
            { model |
                editing = Just ( setFormValue s )
                , disabled = False
            } ! []



-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (++)
            [ h1 [] [ "DIA" |> pageTitle model.action |> text ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView (
    { action
    , disabled
    , editing
    , tableState
    , dias
    } as model ) =
    let
        editable : DIA
        editable = case editing of
            Nothing ->
                new

            Just dia ->
                dia

        showList =
            case dias |> List.length of
                0 ->
                    div [] []
                _ ->
                    Table.view config tableState dias
    in
    case action of
        None ->
            [ div [ "pageMenu" |> class ]
                [ button [ onClick Add ] [ text "Add DIA" ]
                ]
            , showList
            , model.showModal
                |> Modal.view Nothing Nothing
                |> Html.map ModalMsg
            ]

        Adding ->
            [ form [ onSubmit Post ]
                ( (++)
                    ( editable |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]

        Editing ->
            [ form [ onSubmit Put ]
                ( (++)
                    ( editable |> formRows )
                    [ Form.submit disabled Cancel ]
                )
            ]

        _ ->
            [ div [] [] ]


formRows : DIA -> List ( Html Msg )
formRows editable =
    [ Form.text "DIA"
        [ value editable.name
        , onInput ( SetFormValue ( \v -> { editable | name = v } ) )
        , autofocus True
        ]
        []
    ]
-- TABLE CONFIGURATION


config : Table.Config DIA Msg
config =
    Table.customConfig
    -- TODO: Figure out why .id is giving me trouble!
--    { toId = .id
    { toId = .name
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "DIA" .name
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        ]
    , customizations = defaultCustomizations
    }


customColumn : ( DIA -> Table.HtmlDetails Msg ) -> Table.Column DIA Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( DIA -> msg ) -> String -> DIA -> Table.HtmlDetails msg
viewButton msg name dias =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| dias ] [ text name ]
        ]


