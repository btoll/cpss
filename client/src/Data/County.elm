module Data.County exposing (City, County, CountyData, encoder, manyDecoder)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional)
import Json.Encode as Encode



type alias County =
    { id : Int
    , county : String
    , city : String
    , zip : String
    }


-- Let's make City an alias so the intent is clear when reading the code.
type alias City = County


type alias CountyData = ( List County, List City )



decoder : Decoder County
decoder =
    decode County
        |> optional "id" int -1
        |> optional "county" string ""
        |> optional "city" string ""
        |> optional "zip" string ""


manyDecoder : Decoder ( List County )
manyDecoder =
    list decoder


encoder : County -> Encode.Value
encoder county =
    Encode.object
        [ ( "id", Encode.int county.id )
        ]


