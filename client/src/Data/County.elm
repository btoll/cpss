module Data.County exposing (County, CountyWithPager, decoder, encoder, manyDecoder, new, pagingDecoder, succeed)

import Data.Pager
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias County =
    { id : Int
    , name : String
    }


type alias CountyWithPager =
    { counties : List County
    , pager : Data.Pager.Pager
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


pagingDecoder : Decoder CountyWithPager
pagingDecoder =
    decode CountyWithPager
        |> required "counties" manyDecoder
        |> required "pager" Data.Pager.decoder


succeed : a -> Decoder a
succeed =
    Decode.succeed


