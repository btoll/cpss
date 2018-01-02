module Page.Specialist exposing (Model, Msg, init, update, view)

import Data.Specialist exposing (Specialist)
import Html exposing (Html, Attribute, button, div, h1, input, p, text)
import Html.Attributes exposing (checked, style, type_)
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy)
import Http
import Request.Specialist
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Time exposing (Time)



-- MODEL


type alias Model =
    { tableState : Table.State
    , specialists : List Specialist
    }


init : Task Http.Error Model
init =
    Request.Specialist.get
        |> Http.toTask
        |> Task.map ( Model ( Table.initialSort "ID" ) )



-- UPDATE


type Msg
    = GetCompleted ( Result Http.Error ( List Specialist ) )
    | SetTableState Table.State
    | ToggleSelected String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetCompleted ( Ok specialists ) ->
            { model |
                specialists = specialists
                , tableState = Table.initialSort "ID"
            } ! [ Cmd.none ]

        GetCompleted ( Err err ) ->
            { model |
                specialists = []
                , tableState = Table.initialSort "ID"
            } ! [ Cmd.none ]

        ToggleSelected id ->
            { model |
                specialists =
                    model.specialists
                        |> List.map ( toggle id )
            } ! [ Cmd.none ]

        SetTableState newState ->
            { model | tableState = newState
            } ! [ Cmd.none ]


toggle : String -> Specialist -> Specialist
toggle id specialist =
    if specialist.id == id then
        { specialist | selected = not specialist.selected }
    else
        specialist



-- VIEW


view : Model -> Html Msg
view { specialists, tableState } =
    div []
        [ h1 [] [ text "Specialists" ]
        , Table.view config tableState specialists
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
viewButton { selected } =
    Table.HtmlDetails []
        [ button [] [ text "Edit" ]
        ]


viewCheckbox : Specialist -> Table.HtmlDetails Msg
viewCheckbox { selected } =
    Table.HtmlDetails []
        [ input [ type_ "checkbox", checked selected ] []
        ]
------------


