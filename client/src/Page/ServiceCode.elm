module Page.ServiceCode exposing (Model, Msg, init, update, view)

import Data.ServiceCode as ServiceCode exposing (ServiceCode, new)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, class, disabled, for, id, style, type_, value)
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
import Views.Page exposing (ViewAction(..), pageTitle)



-- MODEL


type alias Model =
    { errors : List String
    , tableState : Table.State
    , action : ViewAction
    , editing : Maybe ServiceCode
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , serviceCodes : List ServiceCode
    }



init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , showModal = ( True, Modal.Spinner |> Just )
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

        Delete serviceCode ->
            { model |
                editing = Just serviceCode
                , showModal = ( True , Nothing |> Modal.Delete Modal.Standard |> Just )
                , errors = []
            } ! []

        Deleted ( Ok serviceCode ) ->
            { model |
                serviceCodes = model.serviceCodes |> List.filter ( \m -> serviceCode.id /= m.id )
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

        Edit serviceCode ->
            { model |
                action = Editing
                , disabled = True
                , editing = Just serviceCode
                , errors = []
            } ! []

        FetchedServiceCode ( Ok serviceCodes ) ->
            { model |
                serviceCodes = serviceCodes
                , showModal = ( False, Nothing )
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedServiceCode ( Err err ) ->
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

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just serviceCode ->
                            Request.ServiceCode.post url serviceCode
                                |> Http.toTask
                                |> Task.attempt Posted
                    else
                        Cmd.none
            in
                { model |
                    disabled = True
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
                                |> List.sortBy .name
            in
                { model |
                    action = None
                    , editing = Nothing
                    , errors = []
                    , serviceCodes = sc
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

                        Just serviceCode ->
                            Validate.ServiceCode.errors serviceCode

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just serviceCode ->
                            Request.ServiceCode.put url serviceCode
                                |> Http.toTask
                                |> Task.attempt Putted
                    else
                        Cmd.none
            in
            { model |
                disabled = True
                , errors = errors
            } ! [ subCmd ]

        Putted ( Ok serviceCode ) ->
            let
                serviceCodes =
                    case model.editing of
                        Nothing ->
                            model.serviceCodes

                        Just newServiceCode ->
                            model.serviceCodes
                                |> List.map ( \m ->
                                        if serviceCode.id /= m.id
                                        then m
                                        else { newServiceCode | id = serviceCode.id }
                                    )
            in
                { model |
                    action = None
                    , serviceCodes = serviceCodes
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
            [ h1 [] [ "Service Codes" |> pageTitle model.action |> text ]
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
            [ div [ "buttons" |> class ]
                [ button [ onClick Add ] [ text "Add Service Code" ]
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


