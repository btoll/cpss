module Data.User exposing (User, decoder, encoder)

import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode



type alias User =
    { username : String
    , password : String
    , email : String
    , authLevel : Int
--    , token : AuthToken
--    , bio : Maybe String
--    , image : UserPhoto
--    , createdAt : String
--    , updatedAt : String
    }


decoder : Decoder User
decoder =
    decode User
        |> required "username" string
        |> required "password" string
        |> required "email" string
        |> required "authLevel" int


encoder : User -> Encode.Value
encoder user =
    Encode.object
        [ ( "username", Encode.string user.username )
        , ( "password", Encode.string user.password )
        , ( "email", Encode.string user.email )
        , ( "authLevel", Encode.int user.authLevel )
        ]


