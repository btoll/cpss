module Data.Login exposing (Login, decoder, encoder)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode



type alias Login =
    { username : String
    , password : String
    }


decoder : Decoder Login
decoder =
    decode Login
        |> required "username" string
        |> required "password" string


encoder : Login -> Encode.Value
encoder user =
    Encode.object
        [ ( "username", Encode.string user.username )
        , ( "password", Encode.string user.password )
        ]


