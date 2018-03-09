module Data.Consumer exposing (Consumer, ConsumerWithPager, decoder, encoder, manyDecoder, new, pagingDecoder, succeed)

import Data.Pager
import Json.Decode as Decode exposing (Decoder, bool, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Consumer =
    { id : Int
    , firstname : String
    , lastname : String
    , active : Bool
    , county : Int
    , serviceCode : Int
    , fundingSource : String
    , zip : String
    , bsu : String
    , recipientID : String
    , diaCode : String
    , copay : Float
    , dischargeDate : String
    , other : String
    }


type alias ConsumerWithPager =
    { consumers : List Consumer
    , pager : Data.Pager.Pager
    }


new : Consumer
new =
    { id = -1
    , firstname = ""
    , lastname = ""
    , active = True
    , county = -1
    , serviceCode = -1
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
        |> optional "serviceCode" int -1
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


pagingDecoder : Decoder ConsumerWithPager
pagingDecoder =
    decode ConsumerWithPager
        |> required "consumers" manyDecoder
        |> required "pager" Data.Pager.decoder


encoder : Consumer -> Encode.Value
encoder consumer =
    Encode.object
        [ ( "id", Encode.int consumer.id )
        , ( "firstname", Encode.string consumer.firstname )
        , ( "lastname", Encode.string consumer.lastname )
        , ( "active", Encode.bool consumer.active )
        , ( "county", Encode.int consumer.county )
        , ( "serviceCode", Encode.int consumer.serviceCode )
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


