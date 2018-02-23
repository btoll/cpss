module Data.Pager exposing (Pager, decoder, new)

import Json.Decode as Decode exposing (Decoder, int)
import Json.Decode.Pipeline exposing (decode, required)



type alias Pager =
    { currentPage : Int
    , recordsPerPage : Int
    , totalCount : Int
    , totalPages : Int
    }



new : Pager
new =
    { currentPage = -1
    , recordsPerPage = -1
    , totalCount = -1
    , totalPages = -1
    }



decoder : Decoder Pager
decoder =
    decode Pager
        |> required "currentPage" int
        |> required "recordsPerPage" int
        |> required "totalCount" int
        |> required "totalPages" int


