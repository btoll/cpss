module Util.Form exposing (
    checkboxRow
--    , customColumn
    , dateTimePickerRow
    , disabledTextRow
    , hiddenTextRow
    , passwordRow
    , selectRow
    , floatRow
    , submitRow
--    , tableButton
    , textRow
    , toFloat
    , toInt
--    , toRowAttrs
    )

import Date exposing (Date)
import DateTimePicker
import DateTimePicker.Config exposing (Config, DatePickerConfig, TimePickerConfig, defaultDateTimePickerConfig)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, input, label, option, select, text)
import Html.Attributes exposing (checked, class, disabled, for, hidden, id, selected, step, style, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Table exposing (defaultCustomizations)



checkboxRow : String -> Bool -> ( String -> msg ) -> Html msg
checkboxRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ checked val, disabled False, prepareId name |> id, type_ "checkbox" ] []
    ]


dateTimePickerRow : String
    -> String
    -> { r | date : Dict String Date, datePickerState : Dict String DateTimePicker.State }
    -> Config ( DatePickerConfig TimePickerConfig ) msg
    -> Html msg
dateTimePickerRow name which { date, datePickerState } analogDateTimePickerConfig =
    div []
        [ label [] [ text name ]
        , DateTimePicker.dateTimePickerWithConfig
            analogDateTimePickerConfig
            []
            ( datePickerState
                |> Dict.get which
                |> Maybe.withDefault DateTimePicker.initialState
            )
            ( date
                |> Dict.get which
            )
        ]


disabledTextRow : String -> String -> ( String -> msg ) -> Html msg
disabledTextRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ disabled True, prepareId name |> id, onInput fn, type_ "text", value val ] []
    ]


toFloat : String -> Float
toFloat v =
    String.toFloat v
        |> Result.withDefault 0.00


floatRow : String -> Float -> ( String -> msg ) -> Html msg
floatRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ prepareId name |> id, onInput fn, step "0.01", type_ "number", value ( toString val ) ] []
    ]


hiddenTextRow : String -> String -> Html msg
hiddenTextRow name val =
    div [ hidden True ] [
        label [ prepareId name |> for ] [ text name ]
        , input [ disabled False, prepareId name |> id, type_ "text", value val ] []
    ]


toInt : String -> Int
toInt v =
    String.toInt v
        |> Result.withDefault 0


intRow : String -> Int -> ( String -> msg ) -> Html msg
intRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ disabled False, prepareId name |> id, onInput fn, type_ "text", value ( toString val ) ] []
    ]


passwordRow : String -> String -> ( String -> msg ) -> Html msg
passwordRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ disabled False, prepareId name |> id, onInput fn, type_ "password", value val ] []
    ]


-- Remove any spaces in name (`id` attr doesn't allow for spaces).
prepareId : String -> String
prepareId name =
    name
        |> String.words
        |> String.concat


-- TODO: Break the `select` creation into its own function for use across pages
-- that don't need it to be wrapped in a `div`.
selectRow : String -> String -> List ( String, String ) -> ( String -> msg ) -> Html msg
selectRow name selectedOption list fn =
    let
        opt ( v, t ) =
            option [ selected ( (==) v selectedOption ), value v ] [ text t ]
    in
        div [] [
            label [] [ text name ]
            , list
                |> (::) ( "-1", "-- Select an option --" )
                |> List.map opt
                |> select [ onInput fn ]
        ]


submitRow : Bool -> msg -> Html msg
submitRow isDisabled toMsg =
    div [] [
        input [ disabled isDisabled, type_ "submit" ] []
        , input [ onClick toMsg, type_ "button", value "Cancel" ] []
    ]


textRow : String -> String -> ( String -> msg ) -> Html msg
textRow name val fn =
    div [] [
        label [ prepareId name |> for ] [ text name ]
        , input [ disabled False, prepareId name |> id, onInput fn, type_ "text", value val ] []
    ]


-----------------------------------------------------------------------------
-- Table package helpers
-- http://package.elm-lang.org/packages/evancz/elm-sortable-table/1.0.1/Table
-----------------------------------------------------------------------------


--customColumn : ( msg -> Table.HtmlDetails msg ) -> Table.Column msg msg
--customColumn viewElement =
--    Table.veryCustomColumn
--        { name = ""
--        , viewData = viewElement
--        , sorter = Table.unsortable
--        }


--tableButton : msg -> msg -> Table.HtmlDetails msg
--tableButton msg invoice =
--    Table.HtmlDetails []
--        [ button [ onClick <| msg <| invoice ] [ text ( toString msg ) ]
--        ]


--toRowAttrs : msg -> List ( Attribute msg )
--toRowAttrs { id } =
--    [ style [ ( "background", "white" ) ]
--    ]


