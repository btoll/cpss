module Page.ServiceCode exposing (Model, Msg, init, update, view)

import Data.ServiceCode as ServiceCode exposing (ServiceCode, new)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.ServiceCode
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Validate.ServiceCode
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal



-- MODEL


type alias Model =
    { errors : List ( Validate.ServiceCode.Field, String )
    , tableState : Table.State
    , action : Action
    , editing : Maybe ServiceCode
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , serviceCodes : List ServiceCode
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
    , serviceCodes = []
    } ! [ Request.ServiceCode.list url |> Http.send FetchedServiceCode ]



-- UPDATE


type Msg
    = Add
    | Cancel
    | Delete ServiceCode
    | Deleted ( Result Http.Error ServiceCode )
    | Edit ServiceCode
    | FetchedServiceCode ( Result Http.Error ( List ServiceCode ) )
    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error ServiceCode )
    | Put
    | Putted ( Result Http.Error ServiceCode )
    | SetFormValue ( String -> ServiceCode ) String
    | SetTableState Table.State


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

        Delete serviceCode ->
            { model |
                editing = Just serviceCode
                , showModal = ( True , Modal.Delete |> Just )
            } ! []

        Deleted ( Ok serviceCode ) ->
            { model |
                serviceCodes = model.serviceCodes |> List.filter ( \m -> serviceCode.id /= m.id )
            } ! []

        Deleted ( Err err ) ->
            model ! []
            -- TODO!
--            { model |
--                errors = [ "There was a problem when attempting to delete the service code!" ]
--            } ! []

        Edit serviceCode ->
            { model |
                action = Editing
                , editing = Just serviceCode
            } ! []

        FetchedServiceCode ( Ok serviceCodes ) ->
            { model |
                serviceCodes = serviceCodes
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedServiceCode ( Err err ) ->
            { model |
                serviceCodes = []
                , tableState = Table.initialSort "ID"
            } ! []

        ModalMsg subMsg ->
            let
                cmd =
                    case subMsg |> Modal.update Nothing of
                        ( False, _ ) ->
                            Cmd.none

                        ( True, _ ) ->
                            Maybe.withDefault new model.editing
                                |> Request.ServiceCode.delete url
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

                        Just serviceCode ->
                            Validate.ServiceCode.errors serviceCode

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just serviceCode ->
                            ( None
                            , Request.ServiceCode.post url serviceCode
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

        Posted ( Ok serviceCode ) ->
            let
                sc =
                    case model.editing of
                        Nothing ->
                            model.serviceCodes

                        Just newServiceCode ->
                            model.serviceCodes
                                |> (::) { newServiceCode | id = serviceCode.id }
            in
                { model |
                    serviceCodes = sc
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

                        Just serviceCode ->
                            Validate.ServiceCode.errors serviceCode

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just serviceCode ->
                            ( None
                            , Request.ServiceCode.put url serviceCode
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
                serviceCodes =
                    case model.editing of
                        Nothing ->
                            model.serviceCodes

                        Just newServiceCode ->
                            model.serviceCodes
                                |> List.filter ( \m -> st.id /= m.id )
                                |> (::) { newServiceCode | id = st.id }
            in
                { model |
                    serviceCodes = serviceCodes
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



-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (++)
            [ h1 [] [ text "Service Codes" ]
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
    , serviceCodes
    } as model ) =
    let
        editable : ServiceCode
        editable = case editing of
            Nothing ->
                new

            Just serviceCode ->
                serviceCode

        showList =
            case serviceCodes |> List.length of
                0 ->
                    div [] []
                _ ->
                    Table.view config tableState serviceCodes
    in
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Service Code" ]
            , showList
            , model.showModal
                |> Modal.view Nothing
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


formRows : ServiceCode -> List ( Html Msg )
formRows editable =
    [ Form.text "Service Code"
        [ value editable.name
        , onInput ( SetFormValue ( \v -> { editable | name = v } ) )
        , autofocus True
        ]
        []
    ]
-- TABLE CONFIGURATION


config : Table.Config ServiceCode Msg
config =
    Table.customConfig
    -- TODO: Figure out why .id is giving me trouble!
--    { toId = .id
    { toId = .name
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Service Code" .name
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        ]
    , customizations = defaultCustomizations
    }


customColumn : ( ServiceCode -> Table.HtmlDetails Msg ) -> Table.Column ServiceCode Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( ServiceCode -> msg ) -> String -> ServiceCode -> Table.HtmlDetails msg
viewButton msg name serviceCodes =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| serviceCodes ] [ text name ]
        ]


