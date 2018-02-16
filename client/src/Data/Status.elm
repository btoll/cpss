module Data.Status exposing (Status, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Status =
    { id : Int
    , name : String
    }


new : Status
new =
    { id = -1
    , name = ""
    }


decoder : Decoder Status
decoder =
    decode Status
        |> required "id" int
        |> optional "name" string ""


manyDecoder : Decoder ( List Status )
manyDecoder =
    list decoder


encoder : Status -> Encode.Value
encoder status =
    Encode.object
        [ ( "id", Encode.int status.id )
        , ( "name", Encode.string status.name )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


