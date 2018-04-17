module Data.FundingSource exposing (FundingSource, decoder, encoder, manyDecoder, new, succeed)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias FundingSource =
    { id : Int
    , name : String
    }


new : FundingSource
new =
    { id = -1
    , name = ""
    }


decoder : Decoder FundingSource
decoder =
    decode FundingSource
        |> required "id" int
        |> optional "name" string ""


manyDecoder : Decoder ( List FundingSource )
manyDecoder =
    list decoder


encoder : FundingSource -> Encode.Value
encoder fundingSource =
    Encode.object
        [ ( "id", Encode.int fundingSource.id )
        , ( "name", Encode.string fundingSource.name )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


