module Data.BillSheet exposing
    ( BillSheet
    , BillSheetWithPager
    , decoder
    , encoder
    , manyDecoder
    , new
    , pagingDecoder
    , queryEncoder
    , succeed
    )


import Data.Pager
import Json.Decode as Decode exposing (Decoder, bool, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias BillSheet =
    { id : Int
    , specialist : Int
    , consumer : Int
    , units : Float
    , serviceDate : String
    , serviceCode : Int
    , contractType : String
    , status : Int
    , billedCode : String
    , billedAmount : Float
    , county : Int
    , confirmation : String
    , description : String
    }


type alias BillSheetWithPager =
    { billsheets : List BillSheet
    , pager : Data.Pager.Pager
    }


new : BillSheet
new =
    { id = -1
    , specialist = -1
    , consumer = -1
    , units = 0.0
    , serviceDate = ""
    , serviceCode = -1
    , contractType = ""
    , status = 1            -- Default to `Billed` status.
    , billedCode = ""
    , billedAmount = 0.0
    , county = -1
    , confirmation = ""
    , description = ""
    }


decoder : Decoder BillSheet
decoder =
    decode BillSheet
        |> required "id" int
        |> optional "specialist" int -1
        |> optional "consumer" int -1
        |> optional "units" float 0.0
        |> optional "serviceDate" string ""
        |> optional "serviceCode" int -1
        |> optional "contractType" string ""
        |> optional "status" int -1
        |> optional "billedCode" string ""
        |> optional "billedAmount" float 0.0
        |> optional "county" int -1
        |> optional "confirmation" string ""
        |> optional "description" string ""


manyDecoder : Decoder ( List BillSheet )
manyDecoder =
    list decoder


pagingDecoder : Decoder BillSheetWithPager
pagingDecoder =
    decode BillSheetWithPager
        |> required "billsheets" manyDecoder
        |> required "pager" Data.Pager.decoder


encoder : BillSheet -> Encode.Value
encoder billsheet =
    Encode.object
        [ ( "id", Encode.int billsheet.id )
        , ( "specialist", Encode.int billsheet.specialist )
        , ( "consumer", Encode.int billsheet.consumer )
        , ( "units", Encode.float billsheet.units )
        , ( "serviceDate", Encode.string billsheet.serviceDate )
        , ( "serviceCode", Encode.int billsheet.serviceCode )
        , ( "contractType", Encode.string billsheet.contractType )
        , ( "status", Encode.int billsheet.status )
        , ( "billedCode", Encode.string billsheet.billedCode )
        , ( "billedAmount", Encode.float billsheet.billedAmount )
        , ( "county", Encode.int billsheet.county )
        , ( "confirmation", Encode.string billsheet.confirmation )
        , ( "description", Encode.string billsheet.description )
        ]


queryEncoder : String -> Encode.Value
queryEncoder whereClause =
    Encode.object
        [ ( "whereClause", Encode.string whereClause )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed


