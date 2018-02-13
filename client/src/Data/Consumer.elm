module Data.Consumer exposing (Consumer, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, bool, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Consumer =
    { id : Int
    , firstname : String
    , lastname : String
    , active : Bool
    , county : Int
    , countyCode : String
    , fundingSource : String
    , zip : String
    , bsu : String
    , recipientID : String
    , diaCode : String
    , copay : Float
    , dischargeDate : String
    , other : String
    }


new : Consumer
new =
    { id = -1
    , firstname = ""
    , lastname = ""
    , active = True
    , county = -1
    , countyCode = ""
    , fundingSource = ""
    , zip = ""
    , bsu = ""
    , recipientID = ""
    , diaCode = ""
    , copay = 0.00
    , dischargeDate = ""
    , other = ""
    }


decoder : Decoder Consumer
decoder =
    decode Consumer
        |> required "id" int
        |> optional "firstname" string ""
        |> optional "lastname" string ""
        |> optional "active" bool True
        |> optional "county" int -1
        |> optional "countyCode" string ""
        |> optional "fundingSource" string ""
        |> optional "zip" string ""
        |> optional "bsu" string ""
        |> optional "recipientID" string ""
        |> optional "diaCode" string ""
        |> optional "copay" float 0.0
        |> optional "dischargeDate" string ""
        |> optional "other" string ""


manyDecoder : Decoder ( List Consumer )
manyDecoder =
    list decoder


encoder : Consumer -> Encode.Value
encoder consumer =
    Encode.object
        [ ( "id", Encode.int consumer.id )
        , ( "firstname", Encode.string consumer.firstname )
        , ( "lastname", Encode.string consumer.lastname )
        , ( "active", Encode.bool consumer.active )
        , ( "county", Encode.int consumer.county )
        , ( "countyCode", Encode.string consumer.countyCode )
        , ( "fundingSource", Encode.string consumer.fundingSource )
        , ( "zip", Encode.string consumer.zip )
        , ( "bsu", Encode.string consumer.bsu )
        , ( "recipientID", Encode.string consumer.recipientID )
        , ( "diaCode", Encode.string consumer.diaCode )
        , ( "copay", Encode.float consumer.copay )
        , ( "dischargeDate", Encode.string consumer.dischargeDate )
        , ( "other", Encode.string consumer.other )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


