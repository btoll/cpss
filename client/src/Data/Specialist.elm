module Data.Specialist exposing (Specialist, decoder, encoder, manyDecoder, succeed)

import Json.Decode as Decode exposing (Decoder, bool, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Specialist =
    { id : Int
    , username : String
    , password : String
    , firstname : String
    , lastname : String
    , email : String
    , payrate : Float
    , selected : Bool
    }


decoder : Decoder Specialist
decoder =
    decode Specialist
        |> required "id" int
        |> optional "username" string ""
        |> optional "password" string ""
        |> optional "firstname" string ""
        |> optional "lastname" string ""
        |> optional "email" string ""
        |> optional "payrate" float 0.00
        |> optional "selected" bool False


manyDecoder : Decoder ( List Specialist )
manyDecoder =
    list decoder


encoder : Specialist -> Encode.Value
encoder specialist =
    Encode.object
        [ ( "username", Encode.string specialist.username )
        , ( "password", Encode.string specialist.password )
        , ( "firstname", Encode.string specialist.firstname )
        , ( "lastname", Encode.string specialist.lastname )
        , ( "email", Encode.string specialist.email )
        , ( "payrate", Encode.float specialist.payrate )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed


