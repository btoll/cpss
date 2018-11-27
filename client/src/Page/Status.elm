module Page.Status exposing (Model, Msg, init, update, view)

import Data.Status as Status exposing (Status, new)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, class, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Status
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Validate.Status
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal
import Views.Page exposing (ViewAction(..), pageTitle)



-- MODEL


type alias Model =
--    { errors : List ( Validate.Status.Field, String )
    { errors : List String
    , tableState : Table.State
    , action : ViewAction
    , editing : Maybe Status
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , status : List Status
    }



init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , showModal = ( True, Modal.Spinner |> Just )
    , status = []
    } ! [ Request.Status.list url |> Http.send FetchedStatus ]



-- UPDATE


type Msg
    = Add
    | Cancel
    | Delete Status
    | Deleted ( Result Http.Error Status )
    | Edit Status
    | FetchedStatus ( Result Http.Error ( List Status ) )
    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error Status )
    | Put
    | Putted ( Result Http.Error Status )
    | SetFormValue ( String -> Status ) String
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

        Delete status ->
            { model |
                editing = Just status
                , showModal = ( True , Nothing |> Modal.Delete Modal.Standard |> Just )
                , errors = []
            } ! []

        Deleted ( Ok status ) ->
            { model |
                status = model.status |> List.filter ( \m -> status.id /= m.id )
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
--                errors = (::) ( Validate.Status.ServerError, e ) model.errors
                errors = model.errors
            } ! []

        Edit status ->
            { model |
                action = Editing
                , disabled = True
                , editing = Just status
                , errors = []
            } ! []

        FetchedStatus ( Ok status ) ->
            { model |
                showModal = ( False, Nothing )
                , status = status
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedStatus ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                showModal = ( False, Nothing )
                , status = []
                , tableState = Table.initialSort "ID"
--                , errors = (::) ( Validate.Status.ServerError, e ) model.errors
            } ! []

        ModalMsg subMsg ->
            let
                cmd =
                    case subMsg |> Modal.update Nothing of
                        ( False, _ ) ->
                            Cmd.none

                        ( True, _ ) ->
                            Maybe.withDefault new model.editing
                                |> Request.Status.delete url
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

                        Just status ->
                            Validate.Status.errors status

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just status ->
                            Request.Status.post url status
                                |> Http.toTask
                                |> Task.attempt Posted
                    else
                        Cmd.none
            in
                { model |
                    disabled = True
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok status ) ->
            let
                st =
                    case model.editing of
                        Nothing ->
                            model.status

                        Just newstatus ->
                            model.status
                                |> (::) { newstatus | id = status.id }
                                |> List.sortBy .name
            in
                { model |
                    action = None
                    , editing = Nothing
                    , errors = []
                    , status = st
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
--                errors = (::) ( Validate.Status.ServerError, e ) model.errors
                errors = (::) e model.errors
            } ! []

        Put ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just status ->
                            Validate.Status.errors status

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just status ->
                            Request.Status.put url status
                                |> Http.toTask
                                |> Task.attempt Putted
                    else
                        Cmd.none
            in
                { model |
                    disabled = True
                    , errors = errors
                } ! [ subCmd ]

        Putted ( Ok st ) ->
            let
                status =
                    case model.editing of
                        Nothing ->
                            model.status

                        Just newStatus ->
                            model.status
                                |> List.map ( \m ->
                                        if st.id /= m.id
                                        then m
                                        else { newStatus | id = st.id }
                                    )
            in
                { model |
                    action = None
                    , status = status
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
--                errors = (::) ( Validate.Status.ServerError, e ) model.errors
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
            [ h1 [] [ "Status" |> pageTitle model.action |> text ]
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
    , status
    } as model ) =
    let
        editable : Status
        editable = case editing of
            Nothing ->
                new

            Just status ->
                status

        showList =
            case status |> List.length of
                0 ->
                    div [] []
                _ ->
                    Table.view config tableState status
    in
    case action of
        None ->
            [ div [ "pageMenu" |> class ]
                [ button [ onClick Add ] [ text "Add Status" ]
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


formRows : Status -> List ( Html Msg )
formRows editable =
    [ Form.text "Status"
        [ value editable.name
        , onInput ( SetFormValue ( \v -> { editable | name = v } ) )
        , autofocus True
        ]
        []
    ]
-- TABLE CONFIGURATION


config : Table.Config Status Msg
config =
    Table.customConfig
    -- TODO: Figure out why .id is giving me trouble!
--    { toId = .id
    { toId = .name
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Status" .name
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        ]
    , customizations = defaultCustomizations
    }


customColumn : ( Status -> Table.HtmlDetails Msg ) -> Table.Column Status Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( Status -> msg ) -> String -> Status -> Table.HtmlDetails msg
viewButton msg name status =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| status ] [ text name ]
        ]


