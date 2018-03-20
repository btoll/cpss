module Search.Consumer exposing (Msg, update, view)

import Data.App exposing (App(..), Query)
import Data.Consumer exposing (Consumer)
import Dict exposing (Dict)
import Html exposing (Html, button, div, form, h3, text)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick, onSubmit)
import Views.Form as Form



type alias Model =
    { editing : Consumer
    }



type Msg
    = Cancel
    | Submit
--    | Select Form.Selection Consumer String
    | Select



update : Maybe Query -> Msg -> ( Bool, Maybe Query )
update query msg =
    let
        q =
            query
                |> Maybe.withDefault Dict.empty
    in
    case msg of
        Cancel ->
            ( False, Nothing )

        Select ->
--        Select selectType consumer selection ->
--            let
--                selectionToInt =
--                    selection |> Form.toInt
--
--                newModel a =
--                    { model |
--                        editing = a |> Just
--                        , disabled = False
--                    }
--            in
--            case selectType of
--                Form.CountyID ->
--                    ( { consumer | county = selectionToInt } |> newModel ) ! [
--                        selection |> Request.City.get url |> Http.send ( \result -> result |> Cities |> Fetch )
--                    ]
--
--                Form.DIAID ->
--                    ( { consumer | dia = selectionToInt } |> newModel ) ! []
--
--                Form.ServiceCodeID ->
--                    ( { consumer | serviceCode = selectionToInt } |> newModel ) ! []
--
--                Form.ZipID ->
--                    ( { consumer | zip = selection } |> newModel ) ! []
--
--                _ ->
--                    model ! []
            ( True, Nothing )

        Submit ->
            ( False, Nothing )



view : Html Msg
view =
    form [ onSubmit Submit ]
        [ h3 [] [ "Consumer Search" |> text ]
        , Form.checkbox "Active"
--            [ checked editable.active
--            , onCheck ( SetCheckboxValue ( \v -> { editable | active = v } ) )
--            ]
            []
            []
        , Form.text "Last Name"
            []
--                            [ value editable.bsu
--                            , onInput ( SetFormValue (\v -> { editable | bsu = v } ) )
--                            ]
            []
        , Form.text "First Name"
            []
--                            [ value editable.bsu
--                            , onInput ( SetFormValue (\v -> { editable | bsu = v } ) )
--                            ]
            []
--                        , Form.select "Service Code"
--                            [ id "serviceCodeSelection"
--                            , editable |> Select Form.ServiceCodeID |> onInput
--                            ] (
--                                serviceCodes
--                                    |> List.map ( \m -> ( m.id |> toString, m.name ) )
--                                    |> (::) ( "-1", "-- Select a service code --" )
--                                    |> List.map ( editable.serviceCode |> toString |> Form.option )
--                            )
        , Form.submit False Cancel
        ]


