module Data.Status exposing (Status, decoder, encoder, manyDecoder, succeed)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Status =
    { id : Int
    , status : String
    }


decoder : Decoder Status
decoder =
    decode Status
        |> required "id" int
        |> optional "status" string ""


manyDecoder : Decoder ( List Status )
manyDecoder =
    list decoder


encoder : Status -> Encode.Value
encoder status =
    Encode.object
        [ ( "id", Encode.int status.id )
        , ( "status", Encode.string status.status )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


