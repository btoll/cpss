module Page.Specialist exposing (Model, Msg, init, update, view)

import Data.Specialist exposing (Specialist)
import Html exposing (Html, Attribute, button, div, form, h1, input, label, text)
import Html.Attributes exposing (checked, disabled, for, id, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Lazy exposing (lazy)
import Http
import Request.Specialist
import Table exposing (defaultCustomizations)
import Task exposing (Task)



-- MODEL


type alias Model =
    -- NOTE: Order matters here (see `init`)!
    { tableState : Table.State
    , action : Action
    , editing : Maybe Specialist
    , specialists : List Specialist
    }


type Action = None | Adding | Editing


init : Task Http.Error Model
init =
    Request.Specialist.get
        |> Http.toTask
        |> Task.map ( Model ( Table.initialSort "ID" ) None Nothing )



-- UPDATE


type Msg
    = AddSpecialist
    | EditSpecialist Specialist
    | CancelSpecialist
    | SubmitSpecialist
    | GetCompleted ( Result Http.Error ( List Specialist ) )
    | PostSpecialist
    | SetFormValue ( String -> Specialist ) String
    | SetTableState Table.State
    | ToggleSelected String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddSpecialist ->
            { model |
                action = Adding
                , editing = Nothing
            } ! []

        CancelSpecialist ->
            { model | action = None } ! []

        EditSpecialist specialist ->
            { model |
                action = Editing
                , editing = Just specialist
            } ! []

        SubmitSpecialist ->
            { model | action = None } ! []

        GetCompleted ( Ok specialists ) ->
            { model |
                specialists = specialists
                , tableState = Table.initialSort "ID"
            } ! []

        GetCompleted ( Err err ) ->
            { model |
                specialists = []
                , tableState = Table.initialSort "ID"
            } ! []

        PostSpecialist ->
            model ! []

        SetFormValue setFormValue s ->
            { model | editing = Just ( setFormValue <| s ) } ! []

        ToggleSelected id ->
            { model |
                specialists =
                    model.specialists
                        |> List.map ( toggle id )
            } ! []

        SetTableState newState ->
            { model | tableState = newState
            } ! []


toggle : String -> Specialist -> Specialist
toggle id specialist =
    if specialist.id == id then
        { specialist | selected = not specialist.selected }
    else
        specialist



-- VIEW


view : Model -> Html Msg
view model =
    div []
        ( (::)
            ( h1 [] [ text "Specialists" ] )
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView { action, editing, tableState, specialists } =
    case action of
        None ->
            [ button [ onClick AddSpecialist ] [ text "Add Specialist" ]
            , Table.view config tableState specialists
            ]

        -- Adding | Editing
        _ ->
            [ viewForm editing
            ]


viewForm : Maybe Specialist -> Html Msg
viewForm specialist =
    let
        editable : Specialist
        editable = case specialist of
            Nothing ->
                Specialist "-1" "" "" "" "" "" False

            Just specialist ->
                specialist

        formRow : String -> String -> ( String -> Specialist ) -> Html Msg
        formRow name v func =
            let
                -- Remove any spaces in name (`id` attr doesn't allow for spaces).
                spacesRemoved : String
                spacesRemoved =
                    name
                        |> String.words
                        |> String.concat
            in
                div [] [
                    label [ for spacesRemoved ] [ text name ]
                    , input [ id spacesRemoved, onInput ( SetFormValue func ), type_ "text", value v ] []
                ]
    in
        form [ onSubmit PostSpecialist ] [
            div [] [
                button [ onClick CancelSpecialist ] [ text "Back" ]
            ]
            , formRow "Username" editable.username (\v -> { editable | username = v } )
            , formRow "Password" editable.password (\v -> { editable | password = v } )
            , formRow "First Name" editable.firstname (\v -> { editable | firstname = v } )
            , formRow "Last Name" editable.lastname (\v -> { editable | lastname = v } )
            , formRow "Email" editable.email (\v -> { editable | email = v } )
            , div [] [
                input [ type_ "submit"] []
                , button [ onClick CancelSpecialist ] [ text "Cancel" ]
            ]
        ]


-- TABLE CONFIGURATION


config : Table.Config Specialist Msg
config =
    Table.customConfig
    { toId = .username
    , toMsg = SetTableState
    , columns =
        [ customColumn viewCheckbox
        , Table.stringColumn "Username" .username
        , Table.stringColumn "Password" .password
        , Table.stringColumn "First Name" .firstname
        , Table.stringColumn "Last Name" .lastname
        , Table.stringColumn "Email" .email
        , customColumn viewButton
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : Specialist -> List ( Attribute Msg )
toRowAttrs { id, selected } =
    [ onClick ( ToggleSelected id )
    , style [ ( "background", if selected then "#CEFAF8" else "white" ) ]
    ]


customColumn : ( Specialist -> Table.HtmlDetails Msg ) -> Table.Column Specialist Msg
customColumn viewElement =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewElement
        , sorter = Table.unsortable
        }


-- TODO: Dry!
viewButton : Specialist -> Table.HtmlDetails Msg
viewButton specialist =
    Table.HtmlDetails []
        [ button [ onClick ( EditSpecialist specialist ) ] [ text "Edit" ]
        ]


viewCheckbox : Specialist -> Table.HtmlDetails Msg
viewCheckbox { selected } =
    Table.HtmlDetails []
        [ input [ type_ "checkbox", checked selected ] []
        ]
------------


