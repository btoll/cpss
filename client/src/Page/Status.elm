module Page.Status exposing (Model, Msg, init, update, view)

import Data.Status as Status exposing (Status, new)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, style, type_, value)
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



-- MODEL


type alias Model =
    { errors : List ( Validate.Status.Field, String )
    , tableState : Table.State
    , action : Action
    , editing : Maybe Status
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , status : List Status
    }


type Action
    = None
    | Adding
    | Editing


init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , showModal = ( False, Nothing )
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

        Delete status ->
            { model |
                editing = Just status
                , showModal = ( True , Modal.Delete |> Just )
            } ! []

        Deleted ( Ok status ) ->
            { model |
                status = model.status |> List.filter ( \m -> status.id /= m.id )
            } ! []

        Deleted ( Err err ) ->
            model ! []
            -- TODO!
--            { model |
--                errors = [ "There was a problem when attempting to delete the status!" ]
--            } ! []

        Edit status ->
            { model |
                action = Editing
                , editing = Just status
            } ! []

        FetchedStatus ( Ok status ) ->
            { model |
                status = status
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedStatus ( Err err ) ->
            { model |
                status = []
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

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just status ->
                            ( None
                            , Request.Status.post url status
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

        Posted ( Ok status ) ->
            let
                st =
                    case model.editing of
                        Nothing ->
                            model.status

                        Just newstatus ->
                            model.status
                                |> (::) { newstatus | id = status.id }
            in
                { model |
                    status = st
                    , editing = Nothing
                } ! []

        Posted ( Err err ) ->
            { model |
                editing = Nothing
            } ! []

        Put ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just status ->
                            Validate.Status.errors status

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just status ->
                            ( None
                            , Request.Status.put url status
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

        Putted ( Ok st ) ->
            let
                status =
                    case model.editing of
                        Nothing ->
                            model.status

                        Just newStatus ->
                            model.status
                                |> List.filter ( \m -> st.id /= m.id )
                                |> (::) { newStatus | id = st.id }
            in
                { model |
                    status = status
                    , editing = Nothing
                } ! []

        Putted ( Err err ) ->
            { model |
                editing = Nothing
--                , errors = (::) "There was a problem, the record could not be updated!" model.errors
            } ! []

        SetTableState newState ->
            { model | tableState = newState
            } ! []

        SetFormValue setFormValue s ->
            { model |
                editing = Just ( setFormValue s )
                , disabled = False
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
            [ h1 [] [ text "Status" ]
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
            [ button [ onClick Add ] [ text "Add status" ]
            , showList
            , model.showModal
                |> Modal.view
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


formRows : Status -> List ( Html Msg )
formRows editable =
    [ Form.text "Status"
        [ value editable.status
        , onInput ( SetFormValue ( \v -> { editable | status = v } ) )
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
    { toId = .status
    , toMsg = SetTableState
    , columns =
        [ Table.intColumn "ID" .id
        , Table.stringColumn "Status" .status
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


