module Data.Consumer exposing
    ( Consumer
    , ConsumerWithPager
    , ServiceCode
    , decoder
    , encoder
    , manyDecoder
    , new
    , newServiceCode
    , pagingDecoder
    , queryEncoder
    , succeed
    )

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
    , serviceCodes : List ServiceCode
    , fundingSource : Int
    , zip : String
    , bsu : String
    , recipientID : String
    , dia : Int
    , totalUnits : Float
    , other : String
    }


type alias ConsumerWithPager =
    { consumers : List Consumer
    , pager : Data.Pager.Pager
    }


type alias ServiceCode =
    { id : Int
    , serviceCode : Int
    , units : Float
    }



new : Consumer
new =
    { id = -1
    , firstname = ""
    , lastname = ""
    , active = True
    , county = -1
    , serviceCodes = []
    , fundingSource = -1
    , zip = ""
    , bsu = ""
    , recipientID = ""
    , dia = -1
    , totalUnits = 0.00
    , other = ""
    }


newServiceCode : ServiceCode
newServiceCode =
    { id = -1
    , serviceCode = -1
    , units = 0.0
    }



decoder : Decoder Consumer
decoder =
    decode Consumer
        |> required "id" int
        |> optional "firstname" string ""
        |> optional "lastname" string ""
        |> optional "active" bool True
        |> optional "county" int -1
        |> optional "serviceCodes" manyServiceCodeDecoder []
        |> optional "fundingSource" int -1
        |> optional "zip" string ""
        |> optional "bsu" string ""
        |> optional "recipientID" string ""
        |> optional "dia" int -1
        |> optional "totalUnits" float 0.0
        |> optional "other" string ""


manyDecoder : Decoder ( List Consumer )
manyDecoder =
    list decoder


manyServiceCodeDecoder : Decoder ( List ServiceCode )
manyServiceCodeDecoder =
    list serviceCodeDecoder


pagingDecoder : Decoder ConsumerWithPager
pagingDecoder =
    decode ConsumerWithPager
        |> required "consumers" manyDecoder
        |> required "pager" Data.Pager.decoder


serviceCodeDecoder : Decoder ServiceCode
serviceCodeDecoder =
    decode ServiceCode
        |> optional "id" int -1
        |> required "serviceCode" int
        |> required "units" float


encoder : Consumer -> Encode.Value
encoder consumer =
    Encode.object
        [ ( "id", Encode.int consumer.id )
        , ( "firstname", Encode.string consumer.firstname )
        , ( "lastname", Encode.string consumer.lastname )
        , ( "active", Encode.bool consumer.active )
        , ( "county", Encode.int consumer.county )
        , ( "serviceCodes", consumer.serviceCodes |> manyServiceCodeEncoder >> Encode.list )
        , ( "fundingSource", Encode.int consumer.fundingSource )
        , ( "zip", Encode.string consumer.zip )
        , ( "bsu", Encode.string consumer.bsu )
        , ( "recipientID", Encode.string consumer.recipientID )
        , ( "dia", Encode.int consumer.dia )
        , ( "totalUnits", Encode.float consumer.totalUnits )
        , ( "other", Encode.string consumer.other )
        ]


manyServiceCodeEncoder : List ServiceCode -> List Encode.Value
manyServiceCodeEncoder serviceCodes =
    serviceCodes
        |> List.map serviceCodeEncoder


serviceCodeEncoder : ServiceCode -> Encode.Value
serviceCodeEncoder serviceCode =
    Encode.object
        [ ( "id", Encode.int serviceCode.id )
        , ( "serviceCode", Encode.int serviceCode.serviceCode )
        , ( "units", Encode.float serviceCode.units )
        ]


queryEncoder : String -> Encode.Value
queryEncoder whereClause =
    Encode.object
        [ ( "whereClause", Encode.string whereClause )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


