module Data.ServiceCode exposing (ServiceCode, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias ServiceCode =
    { id : Int
    , name : String
    , unitRate : Float
    , description : String
    }


new : ServiceCode
new =
    { id = -1
    , name = ""
    , unitRate = 0.0
    , description = ""
    }


decoder : Decoder ServiceCode
decoder =
    decode ServiceCode
        |> required "id" int
        |> optional "name" string ""
        |> optional "unitRate" float 0.0
        |> optional "description" string ""


manyDecoder : Decoder ( List ServiceCode )
manyDecoder =
    list decoder


encoder : ServiceCode -> Encode.Value
encoder serviceCode =
    Encode.object
        [ ( "id", Encode.int serviceCode.id )
        , ( "name", Encode.string serviceCode.name )
        , ( "unitRate", Encode.float serviceCode.unitRate )
        , ( "description", Encode.string serviceCode.description )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


