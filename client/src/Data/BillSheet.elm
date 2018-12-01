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
    , realSpecialist : Int -- Some actions may have the actual user send a different specialist, so we need to be able to know who the user actually is.
    , consumer : Int
    , units : String
    , serviceDate : String
    , serviceCode : Int
    , status : Int
    , billedAmount : Float
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
    , realSpecialist = -1
    , consumer = -1
    , units = ""
    , serviceDate = ""
    , serviceCode = -1
    , status = 1            -- Default to `Billed` status.
    , billedAmount = 0.0
    , confirmation = ""
    , description = ""
    }


decoder : Decoder BillSheet
decoder =
    decode BillSheet
        |> required "id" int
        |> optional "specialist" int -1
        |> optional "realSpecialist" int -1
        |> optional "consumer" int -1
        |> optional "units" string ""
        |> optional "serviceDate" string ""
        |> optional "serviceCode" int -1
        |> optional "status" int -1
        |> optional "billedAmount" float 0.0
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
        , ( "realSpecialist", Encode.int billsheet.realSpecialist )
        , ( "consumer", Encode.int billsheet.consumer )
        , ( "units", Encode.string billsheet.units )
        , ( "serviceDate", Encode.string billsheet.serviceDate )
        , ( "serviceCode", Encode.int billsheet.serviceCode )
        , ( "status", Encode.int billsheet.status )
        , ( "billedAmount", Encode.float billsheet.billedAmount )
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


