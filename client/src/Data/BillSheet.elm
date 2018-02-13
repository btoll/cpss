module Data.BillSheet exposing (BillSheet, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, bool, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias BillSheet =
    { id : Int
    , recipientID : String
    , serviceDate : String
    , billedAmount : Float
    , consumer : Int
    , status : Int
    , confirmation : String
    , service : Int
    , county : Int
    , specialist : Int
    , recordNumber : String
    }



new : BillSheet
new =
    { id = -1
    , recipientID = ""
    , serviceDate = ""
    , billedAmount = 0.0
    , consumer = -1
    , status = -1
    , confirmation = ""
    , service = -1
    , county = -1
    , specialist = -1
    , recordNumber = ""
    }


decoder : Decoder BillSheet
decoder =
    decode BillSheet
        |> required "id" int
        |> optional "recipientID" string ""
        |> optional "serviceDate" string ""
        |> optional "billedAmount" float 0.0
        |> optional "consumer" int -1
        |> optional "status" int -1
        |> optional "confirmation" string ""
        |> optional "service" int -1
        |> optional "county" int -1
        |> optional "specialist" int -1
        |> optional "recordNumber" string ""


manyDecoder : Decoder ( List BillSheet )
manyDecoder =
    list decoder


encoder : BillSheet -> Encode.Value
encoder billsheet =
    Encode.object
        [ ( "id", Encode.int billsheet.id )
        , ( "recipientID", Encode.string billsheet.recipientID )
        , ( "serviceDate", Encode.string billsheet.serviceDate )
        , ( "billedAmount", Encode.float billsheet.billedAmount )
        , ( "consumer", Encode.int billsheet.consumer )
        , ( "status", Encode.int billsheet.status )
        , ( "confirmation", Encode.string billsheet.confirmation )
        , ( "service", Encode.int billsheet.service )
        , ( "county", Encode.int billsheet.county )
        , ( "specialist", Encode.int billsheet.specialist )
        , ( "recordNumber", Encode.string billsheet.recordNumber )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


