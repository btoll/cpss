module Data.County exposing (County, encoder, manyDecoder, new)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias County =
    { id : Int
    , name : String
    }



new : County
new =
    { id = -1
    , name = ""
    }



decoder : Decoder County
decoder =
    decode County
        |> required "id" int
        |> required "name" string


manyDecoder : Decoder ( List County )
manyDecoder =
    list decoder


encoder : County -> Encode.Value
encoder county =
    Encode.object
        [ ( "id", Encode.int county.id )
        , ( "name", Encode.string county.name )
        ]


