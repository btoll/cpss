module Page.FundingSource exposing (Model, Msg, init, update, view)

import Data.FundingSource as FundingSource exposing (FundingSource, new)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, section, text)
import Html.Attributes exposing (action, autofocus, checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.FundingSource
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Validate.FundingSource
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal
import Views.Page exposing (ViewAction(..), pageTitle)



-- MODEL


type alias Model =
    { errors : List String
    , tableState : Table.State
    , action : ViewAction
    , editing : Maybe FundingSource
    , disabled : Bool
    , showModal : ( Bool, Maybe Modal.Modal )
    , fundingSources : List FundingSource
    }



init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , showModal = ( False, Nothing )
    , fundingSources = []
    } ! [ Request.FundingSource.list url |> Http.send FetchedFundingSource ]



-- UPDATE


type Msg
    = Add
    | Cancel
    | Delete FundingSource
    | Deleted ( Result Http.Error FundingSource )
    | Edit FundingSource
    | FetchedFundingSource ( Result Http.Error ( List FundingSource ) )
    | ModalMsg Modal.Msg
    | Post
    | Posted ( Result Http.Error FundingSource )
    | Put
    | Putted ( Result Http.Error FundingSource )
    | SetFormValue ( String -> FundingSource ) String
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

        Delete fundingSource ->
            { model |
                editing = Just fundingSource
                , showModal = ( True , Modal.Delete |> Just )
                , errors = []
            } ! []

        Deleted ( Ok fundingSource ) ->
            { model |
                fundingSources = model.fundingSources |> List.filter ( \m -> fundingSource.id /= m.id )
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

        Edit fundingSource ->
            { model |
                action = Editing
                , disabled = True
                , editing = Just fundingSource
                , errors = []
            } ! []

        FetchedFundingSource ( Ok fundingSources ) ->
            { model |
                fundingSources = fundingSources
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedFundingSource ( Err err ) ->
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
                                |> Request.FundingSource.delete url
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

                        Just fundingSource ->
                            Validate.FundingSource.errors fundingSource

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just fundingSource ->
                            ( None
                            , Request.FundingSource.post url fundingSource
                                |> Http.toTask
                                |> Task.attempt Posted
                            )
                    else
                        ( Adding, Cmd.none )
            in
                { model |
                    action = action
                    , disabled = True
                    , editing = if errors |> List.isEmpty then Nothing else model.editing
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok fundingSource ) ->
            let
                sc =
                    case model.editing of
                        Nothing ->
                            model.fundingSources

                        Just newFundingSource ->
                            model.fundingSources
                                |> (::) { newFundingSource | id = fundingSource.id }
            in
                { model |
                    fundingSources = sc
                    , editing = Nothing
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
                editing = Nothing
                , errors = (::) e model.errors
            } ! []

        Put ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just fundingSource ->
                            Validate.FundingSource.errors fundingSource

                ( action, subCmd ) = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            ( None, Cmd.none )

                        Just fundingSource ->
                            ( None
                            , Request.FundingSource.put url fundingSource
                                |> Http.toTask
                                |> Task.attempt Putted
                            )
                    else
                        ( Editing, Cmd.none )
            in
                { model |
                    action = action
                    , disabled = True
                    , errors = errors
                } ! [ subCmd ]

        Putted ( Ok st ) ->
            let
                fundingSources =
                    case model.editing of
                        Nothing ->
                            model.fundingSources

                        Just newFundingSource ->
                            model.fundingSources
                                |> List.filter ( \m -> st.id /= m.id )
                                |> (::) { newFundingSource | id = st.id }
            in
                { model |
                    fundingSources = fundingSources
                    , editing = Nothing
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
                editing = Nothing
                , errors = (::) e model.errors
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
            [ h1 [] [ "FundingSource" |> pageTitle model.action |> text ]
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
    , fundingSources
    } as model ) =
    let
        editable : FundingSource
        editable = case editing of
            Nothing ->
                new

            Just fundingSource ->
                fundingSource

        showList =
            case fundingSources |> List.length of
                0 ->
                    div [] []
                _ ->
                    Table.view config tableState fundingSources
    in
    case action of
        None ->
            [ button [ onClick Add ] [ text "Add Funding Source" ]
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

        _ ->
            [ div [] [] ]


formRows : FundingSource -> List ( Html Msg )
formRows editable =
    [ Form.text "Funding Source"
        [ value editable.name
        , onInput ( SetFormValue ( \v -> { editable | name = v } ) )
        , autofocus True
        ]
        []
    ]
-- TABLE CONFIGURATION


config : Table.Config FundingSource Msg
config =
    Table.customConfig
    -- TODO: Figure out why .id is giving me trouble!
--    { toId = .id
    { toId = .name
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Funding Source" .name
        , customColumn ( viewButton Edit "Edit" )
        , customColumn ( viewButton Delete "Delete" )
        ]
    , customizations = defaultCustomizations
    }


customColumn : ( FundingSource -> Table.HtmlDetails Msg ) -> Table.Column FundingSource Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( FundingSource -> msg ) -> String -> FundingSource -> Table.HtmlDetails msg
viewButton msg name fundingSources =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| fundingSources ] [ text name ]
        ]


