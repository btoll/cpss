module Data.BillSheet exposing (BillSheet, decoder, encoder, manyDecoder, succeed)

import Json.Decode as Decode exposing (Decoder, bool, float, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias BillSheet =
    { id : String
    , recipientID : String
    , serviceDate : String
    , billedAmount : Float
    , consumer : String
    , status : String
    , confirmation : String
    , service : String
    , county : String
    , specialist : String
    , recordNumber : String
    , selected : Bool
    }


decoder : Decoder BillSheet
decoder =
    decode BillSheet
        |> required "id" string
        |> required "recipientID" string
        |> required "serviceDate" string
        |> required "billedAmount" float
        |> required "consumer" string
        |> required "status" string
        |> required "confirmation" string
        |> required "service" string
        |> required "county" string
        |> required "specialist" string
        |> required "recordNumber" string
        |> optional "selected" bool False


manyDecoder : Decoder ( List BillSheet )
manyDecoder =
    list decoder


encoder : BillSheet -> Encode.Value
encoder billsheet =
    Encode.object
        [ ( "recipientID", Encode.string billsheet.recipientID )
        , ( "serviceDate", Encode.string billsheet.serviceDate )
        , ( "billedAmount", Encode.float billsheet.billedAmount )
        , ( "consumer", Encode.string billsheet.consumer )
        , ( "status", Encode.string billsheet.status )
        , ( "confirmation", Encode.string billsheet.confirmation )
        , ( "service", Encode.string billsheet.service )
        , ( "county", Encode.string billsheet.county )
        , ( "specialist", Encode.string billsheet.specialist )
        , ( "recordNumber", Encode.string billsheet.recordNumber )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed

