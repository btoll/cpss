module Util.Date exposing (now, parse, rfc3339, simple, unsafeFromString)

import Date exposing (Date)
import Dict exposing (Dict)
import Task exposing (Task)



type alias Parsed =
    { year : String
    , month : String
    , day : String
    , hour : String
    , minute : String
    }


fromMonthString : Dict String String
fromMonthString =
    Dict.fromList
    [
        ( "Jan", "01" )
        , ( "Feb", "02" )
        , ( "Mar", "03" )
        , ( "Apr", "04" )
        , ( "May", "05" )
        , ( "Jun", "06" )
        , ( "Jul", "07" )
        , ( "Aug", "08" )
        , ( "Sep", "09" )
        , ( "Oct", "10" )
        , ( "Nov", "11" )
        , ( "Dec", "12" )
    ]


fromMonthInt : Dict String String
fromMonthInt =
    Dict.fromList
    [
        ( "01", "Jan" )
        , ( "02", "Feb" )
        , ( "03", "Mar" )
        , ( "04", "Apr" )
        , ( "05", "May" )
        , ( "06", "Jun" )
        , ( "07", "Jul" )
        , ( "08", "Aug" )
        , ( "09", "Sep" )
        , ( "10", "Oct" )
        , ( "11", "Nov" )
        , ( "12", "Dec" )
    ]


now : ( Date -> msg ) -> Cmd msg
now msg =
    Date.now
        |> Task.perform msg


parse : Date -> Parsed
parse date =
    let
        year = toString ( Date.year date )

        month = toString ( Date.month date )
        mo = Dict.get month fromMonthString |> Maybe.withDefault "--"

        day = toString ( Date.day date )
        d = if ( day |> String.length ) == 1 then ( (++) "0" day ) else day

        hour = toString ( Date.hour date )
        h = if ( hour |> String.length ) == 1 then ( (++) "0" hour ) else hour

        minute = toString ( Date.minute date )
        min = if ( minute |> String.length ) == 1 then ( (++) "0" minute ) else minute
    in
        { year = year
        , month = mo
        , day = d
        , hour = h
        , minute = min
        }


rfc3339 : Date -> String
rfc3339 date =
    let
        h = date |> parse
    in
    h.year ++ "-" ++ h.month ++ "-" ++ h.day ++ "T" ++ h.hour ++ ":" ++ h.minute ++ ":00+00:00"



simple : Date -> String
simple date =
    let
        h = date |> parse
    in
    h.year ++ "-" ++ h.month ++ "-" ++ h.day


-- http://package.elm-lang.org/packages/rluiten/elm-date-extra/latest
-- https://github.com/rluiten/elm-date-extra/blob/9.2.3/src/Date/Extra/Utils.elm
--
-- NOTE: I found that passing a string date like "2018/02/02" would return a date
-- of:
--
--      <Fri Feb 01 2018 00:00:00 GMT-0500 (EST)>
--
-- Using the month string, i.e., "Feb" gives me the expected date.
unsafeFromString : String -> Date
unsafeFromString stringDate =
    let
        parts =
            stringDate
                |> String.split "-"

        year =
            parts
                |> List.head
                |> Maybe.withDefault ""

        month =
            parts
                |> List.drop 1
                |> List.head
                |> Maybe.withDefault ""

        m =
            fromMonthInt
                |> Dict.get month
                |> Maybe.withDefault ""

        day =
            parts
                |> List.drop 2
                |> List.head
                |> Maybe.withDefault ""

        sd =
            [ year
            , m
            , day
            ] |> String.join "-"
    in
    case Date.fromString sd of
        Err err ->
            Debug.crash "unsafeFromString"

        Ok date ->
            date


