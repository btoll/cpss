module Data.ServiceCode exposing (ServiceCode, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias ServiceCode =
    { id : Int
    , name : String
    }


new : ServiceCode
new =
    { id = -1
    , name = ""
    }


decoder : Decoder ServiceCode
decoder =
    decode ServiceCode
        |> required "id" int
        |> optional "name" string ""


manyDecoder : Decoder ( List ServiceCode )
manyDecoder =
    list decoder


encoder : ServiceCode -> Encode.Value
encoder serviceCode =
    Encode.object
        [ ( "id", Encode.int serviceCode.id )
        , ( "name", Encode.string serviceCode.name )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


