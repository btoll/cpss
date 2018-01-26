module Page.Status exposing (Model, Msg, init, update, view)

import Data.Status as Status exposing (Status)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Status
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Util.Form as Form



-- MODEL


type alias Model =
    -- NOTE: Order matters here (see `init`)!
    { tableState : Table.State
    , action : Action
    , editing : Maybe Status
    , disabled : Bool
    , status : List Status
    }


type Action
    = None
    | Adding


init : String -> Task Http.Error Model
init url =
    Request.Status.get url
        |> Http.toTask
        |> Task.map ( Model ( Table.initialSort "ID" ) None Nothing True )



-- UPDATE


type Msg
    = Add
    | Cancel
    | Delete Status
    | Deleted ( Result Http.Error Status )
    | Getted ( Result Http.Error ( List Status ) )
    | Post
    | Posted ( Result Http.Error Status )
    | SetTextValue ( String -> Status ) String
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
            } ! []

        Delete status ->
            let
                subCmd =
                    Request.Status.delete url status
                        |> Http.toTask
                        |> Task.attempt Deleted
            in
                { model |
                    action = None
                    , editing = Nothing
                } ! [ subCmd ]

        Deleted ( Ok deletedstatus ) ->
            { model |
                status = model.status |> List.filter ( \m -> deletedstatus.id /= m.id )
            } ! []

        Deleted ( Err err ) ->
            model ! []

        Getted ( Ok status ) ->
            { model |
                status = status
                , tableState = Table.initialSort "ID"
            } ! []

        Getted ( Err err ) ->
            { model |
                status = []
                , tableState = Table.initialSort "ID"
            } ! []

        Post ->
            let
                subCmd = case model.editing of
                    Nothing ->
                        Cmd.none

                    Just status ->
                        Request.Status.post url status
                            |> Http.toTask
                            |> Task.attempt Posted
            in
                { model |
                    action = None
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


        SetTableState newState ->
            { model | tableState = newState
            } ! []

        SetTextValue setTextValue s ->
            { model |
                editing = Just ( setTextValue s )
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
        ( (::)
            ( h1 [] [ text "Status" ] )
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
                Status -1 ""

            Just status ->
                status
    in
        case action of
            None ->
                [ button [ onClick Add ] [ text "Add status" ]
                , Table.view config tableState status
                ]

            Adding ->
                [ form [ onSubmit Post ] [
                    Form.textRow "Status" editable.status ( SetTextValue (\v -> { editable | status = v }) )
                    , Form.submitRow disabled Cancel
                    ]
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
        , customColumn ( viewButton Delete "Delete" )
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : Status -> List ( Attribute Msg )
toRowAttrs { id } =
    [ style [ ( "background", "white" ) ]
    ]


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


