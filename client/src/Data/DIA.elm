module Data.DIA exposing (DIA, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias DIA =
    { id : Int
    , name : String
    }


new : DIA
new =
    { id = -1
    , name = ""
    }


decoder : Decoder DIA
decoder =
    decode DIA
        |> required "id" int
        |> optional "name" string ""


manyDecoder : Decoder ( List DIA )
manyDecoder =
    list decoder


encoder : DIA -> Encode.Value
encoder dia =
    Encode.object
        [ ( "id", Encode.int dia.id )
        , ( "name", Encode.string dia.name )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


