module Data.Specialist exposing (Specialist, manyDecoder)

import Json.Decode as Decode exposing (Decoder, bool, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias Specialist =
    { id : String
    , username : String
    , password : String
    , firstname : String
    , lastname : String
    , email : String
    , selected : Bool
    }


oneDecoder : Decoder Specialist
oneDecoder =
    decode Specialist
        |> required "id" string
        |> required "username" string
        |> required "password" string
        |> required "firstname" string
        |> required "lastname" string
        |> required "email" string
        |> optional "selected" bool False


manyDecoder : Decoder ( List Specialist )
manyDecoder =
    list oneDecoder


--encoder : Specialist -> Encode.Value
--encoder specialist =
--    Encode.object
--        [ ( "name", Encode.string sport.name )
--        ]


