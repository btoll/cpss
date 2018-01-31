module Data.Consumer exposing (Consumer, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, bool, float, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Consumer =
    { id : String
    , firstname : String
    , lastname : String
    , active : Bool
    , countyName : String
    , countyCode : String
    , fundingSource : String
    , zip : String
    , bsu : String
    , recipientID : String
    , diaCode : String
    , consumerID : String
    , copay : Float
    , dischargeDate : String
    , other : String
    , selected : Bool
    }


new : Consumer
new =
    { id = ""
    , firstname = ""
    , lastname = ""
    , active = True
    , countyName = ""
    , countyCode = ""
    , fundingSource = ""
    , zip = ""
    , bsu = ""
    , recipientID = ""
    , diaCode = ""
    , consumerID = ""
    , copay = 0.00
    , dischargeDate = ""
    , other = ""
    , selected = False
    }


decoder : Decoder Consumer
decoder =
    decode Consumer
        |> required "id" string
        |> required "firstname" string
        |> required "lastname" string
        |> required "active" bool
        |> required "countyName" string
        |> required "countyCode" string
        |> required "fundingSource" string
        |> required "zip" string
        |> required "bsu" string
        |> required "recipientID" string
        |> required "diaCode" string
        |> required "consumerID" string
        |> required "copay" float
        |> required "dischargeDate" string
        |> required "other" string
        |> optional "selected" bool False


manyDecoder : Decoder ( List Consumer )
manyDecoder =
    list decoder


encoder : Consumer -> Encode.Value
encoder consumer =
    Encode.object
        [ ( "firstname", Encode.string consumer.firstname )
        , ( "lastname", Encode.string consumer.lastname )
        , ( "active", Encode.bool consumer.active )
        , ( "countyName", Encode.string consumer.countyName )
        , ( "countyName", Encode.string consumer.countyCode )
        , ( "fundingSource", Encode.string consumer.fundingSource )
        , ( "zip", Encode.string consumer.zip )
        , ( "bsu", Encode.string consumer.bsu )
        , ( "recipientID", Encode.string consumer.recipientID )
        , ( "diaCode", Encode.string consumer.diaCode )
        , ( "consumerID", Encode.string consumer.consumerID )
        , ( "copay", Encode.float consumer.copay )
        , ( "dischargeDate", Encode.string consumer.dischargeDate )
        , ( "other", Encode.string consumer.other )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed


