module Data.City exposing (City, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias City =
    { id : Int
    , name : String
    , zip : String
    , countyID : Int
    , state : String
    }



new : City
new =
    { id = -1
    , name = ""
    , zip = ""
    , countyID = -1
    , state = ""
    }



decoder : Decoder City
decoder =
    decode City
        |> required "id" int
        |> required "name" string
        |> required "zip" string
        |> required "countyID" int
        |> required "state" string


manyDecoder : Decoder ( List City )
manyDecoder =
    list decoder


encoder : City -> Encode.Value
encoder city =
    Encode.object
        [ ( "id", Encode.int city.id )
        , ( "name", Encode.string city.name )
        , ( "zip", Encode.string city.zip )
        , ( "countyID", Encode.int city.countyID )
        , ( "state", Encode.string city.state )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


