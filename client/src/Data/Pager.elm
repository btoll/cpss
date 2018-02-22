module Data.Pager exposing (Pager, decoder)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, required)



type alias Pager =
    { currentPage : Int
    , recordsPerPage : Int
    , totalCount : Int
    }



decoder : Decoder Pager
decoder =
    decode Pager
        |> required "currentPage" int
        |> required "recordsPerPage" int
        |> required "totalCount" int


