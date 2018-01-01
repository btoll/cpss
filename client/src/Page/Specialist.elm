module Page.Specialist exposing (Model, Msg, init, update, view)

import Data.Specialist exposing (Specialist)
import Html exposing (Html, Attribute, div, h1, input, p, text)
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
--  | ToggleSelected String


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

--    ToggleSelected name ->
--        ( { model | specialists = List.map (toggle name) model.specialists }
--        , Cmd.none
--        )

    SetTableState newState ->
        ( { model | tableState = newState }
        , Cmd.none
        )


--toggle : String -> Specialist -> Specialist
--toggle name sight =
--  if sight.name == name then
--    { sight | selected = not sight.selected }
--
--  else
--    sight



-- VIEW


view : Model -> Html Msg
view { specialists, tableState } =
  div []
    [ h1 [] [ text "Trip Planner" ]
--    , lazy viewSummary specialists
    , Table.view config tableState specialists
    ]


--viewSummary : List Specialist -> Html msg
--viewSummary allSpecialists =
--  case List.filter .selected allSpecialists of
--    [] ->
--      p [] [ text "Click the sights you want to see on your trip!" ]
--
--    sights ->
--      let
--        time =
--          List.sum (List.map .time sights)
--
--        price =
--          List.sum (List.map .price sights)
--
--        summary =
--          "That is " ++ timeToString time ++ " of fun, costing $" ++ toString price
--      in
--        p [] [ text summary ]


timeToString : Time -> String
timeToString time =
  let
    hours =
      case floor (Time.inHours time) of
        0 -> ""
        1 -> "1 hour"
        n -> toString n ++ " hours"

    minutes =
      case rem (round (Time.inMinutes time)) 60 of
        0 -> ""
        1 -> "1 minute"
        n -> toString n ++ " minutes"
  in
    hours ++ " " ++ minutes



-- TABLE CONFIGURATION


config : Table.Config Specialist Msg
config =
  Table.customConfig
    { toId = .name
    , toMsg = SetTableState
    , columns =
        [ --checkboxColumn
        Table.stringColumn "ID" .id
        , Table.stringColumn "Name" .name
--        , timeColumn
--        , Table.floatColumn "Price" .price
--        , Table.floatColumn "Rating" .rating
        ]
    , customizations =
        { defaultCustomizations | rowAttrs = toRowAttrs }
    }


toRowAttrs : Specialist -> List (Attribute Msg)
toRowAttrs sight =
--  [ onClick (ToggleSelected sight.name)
  [
--  , style [ ("background", if sight.selected then "#CEFAF8" else "white") ]
  style [ ( "background", "#CEFAF8" ) ]
  ]


--timeColumn : Table.Column Specialist Msg
--timeColumn =
--  Table.customColumn
--    { name = "Time"
--    , viewData = timeToString << .time
--    , sorter = Table.increasingOrDecreasingBy .time
--    }


--checkboxColumn : Table.Column Specialist Msg
--checkboxColumn =
--  Table.veryCustomColumn
--    { name = ""
--    , viewData = viewCheckbox
--    , sorter = Table.unsortable
--    }

--viewCheckbox : Specialist -> Table.HtmlDetails Msg
--viewCheckbox {selected} =
--  Table.HtmlDetails []
--    [ input [ type_ "checkbox", checked selected ] []
--    ]



-- SIGHTS


--type alias Specialist =
--  { name : String
--  , time : Time
--  , price : Float
--  , rating : Float
--  , selected : Bool
--  }
--
--
--missionSights : List Sight
--missionSights =
--  [ Sight "Eat a Burrito" (30 * Time.minute) 7 4.6 False
--  , Sight "Buy drugs in Dolores park" Time.hour 20 4.8 False
--  , Sight "Armory Tour" (1.5 * Time.hour) 27 4.5 False
--  , Sight "Tartine Bakery" Time.hour 10 4.1 False
--  , Sight "Have Brunch" (2 * Time.hour) 25 4.2 False
--  , Sight "Get catcalled at BART" (5 * Time.minute) 0 1.6 False
--  , Sight "Buy a painting at \"Stuff\"" (45 * Time.minute) 400 4.7 False
--  , Sight "McDonalds at 24th" (20 * Time.minute) 5 2.8 False
--  ]
