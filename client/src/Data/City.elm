module Data.City exposing (City, Cities, decoder, encoder, new, pagingDecoder, succeed)

import Data.Pager
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


type alias Cities =
    { cities : List City
    , pager : Data.Pager.Pager
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


encoder : City -> Encode.Value
encoder city =
    Encode.object
        [ ( "id", Encode.int city.id )
        , ( "name", Encode.string city.name )
        , ( "zip", Encode.string city.zip )
        , ( "countyID", Encode.int city.countyID )
        , ( "state", Encode.string city.state )
        ]


pagingDecoder : Decoder Cities
pagingDecoder =
    decode Cities
        |> required "cities" ( list decoder )
        |> required "pager" Data.Pager.decoder


succeed : a -> Decoder a
succeed =
    Decode.succeed


