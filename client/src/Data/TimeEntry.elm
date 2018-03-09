module Data.TimeEntry exposing (TimeEntry, TimeEntryWithPager, decoder, encoder, manyDecoder, new, pagingDecoder, succeed)

import Data.Pager
import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias TimeEntry =
    { id : Int
    , specialist : Int
    , consumer : Int
    , serviceDate : String
    , serviceCode : Int
    , hours : Float
    , description : String
    , county : Int
    , contractType : String
    , billingCode : String
    }


type alias TimeEntryWithPager =
    { timeEntries : List TimeEntry
    , pager : Data.Pager.Pager
    }


new : TimeEntry
new =
    { id = -1
    , specialist = -1
    , consumer = -1
    , serviceDate = ""
    , serviceCode = -1
    , hours = 0.0
    , description = ""
    , county = -1
    , contractType = ""
    , billingCode = ""
    }


decoder : Decoder TimeEntry
decoder =
    decode TimeEntry
        |> required "id" int
        |> optional "specialist" int -1
        |> optional "consumer" int -1
        |> optional "serviceDate" string ""
        |> optional "serviceCode" int -1
        |> optional "hours" float 0.0
        |> optional "description" string ""
        |> optional "county" int -1
        |> optional "contractType" string ""
        |> optional "billingCode" string ""


manyDecoder : Decoder ( List TimeEntry )
manyDecoder =
    list decoder


pagingDecoder : Decoder TimeEntryWithPager
pagingDecoder =
    decode TimeEntryWithPager
        |> required "timeEntries" manyDecoder
        |> required "pager" Data.Pager.decoder


encoder : TimeEntry -> Encode.Value
encoder timeEntry =
    Encode.object
        [ ( "id", Encode.int timeEntry.id )
        , ( "specialist", Encode.int timeEntry.specialist )
        , ( "consumer", Encode.int timeEntry.consumer )
        , ( "serviceDate", Encode.string timeEntry.serviceDate )
        , ( "serviceCode", Encode.int timeEntry.serviceCode )
        , ( "hours", Encode.float timeEntry.hours )
        , ( "description", Encode.string timeEntry.description )
        , ( "county", Encode.int timeEntry.county )
        , ( "contractType", Encode.string timeEntry.contractType )
        , ( "billingCode", Encode.string timeEntry.billingCode )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


