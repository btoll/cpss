module Data.PayHistory exposing (PayHistory, decoder, manyDecoder, new)

import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode



type alias PayHistory =
    { id : Int
    , specialist : Int
    , changeDate : String
    , payrate : Float
    }


new : PayHistory
new =
    { id = -1
    , specialist = -1
    , changeDate = "1970-01-01"
    , payrate = 0.0
    }


decoder : Decoder PayHistory
decoder =
    decode PayHistory
        |> required "id" int
        |> required "specialist" int
        |> required "changeDate" string
        |> required "payrate" float


manyDecoder : Decoder ( List PayHistory )
manyDecoder =
    list decoder


