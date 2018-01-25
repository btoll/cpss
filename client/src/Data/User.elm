module Data.User exposing (User, decoder, encoder, manyDecoder, succeed)

import Json.Decode as Decode exposing (Decoder, bool, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias User =
    { id : Int
    , username : String
    , password : String
    , firstname : String
    , lastname : String
    , email : String
    , payrate : Float
    , authLevel : Int
    }


decoder : Decoder User
decoder =
    decode User
        |> required "id" int
        |> optional "username" string ""
        |> optional "password" string ""
        |> optional "firstname" string ""
        |> optional "lastname" string ""
        |> optional "email" string ""
        |> optional "payrate" float 0.00
        |> optional "authLevel" int 1


manyDecoder : Decoder ( List User )
manyDecoder =
    list decoder


encoder : User -> Encode.Value
encoder user =
    Encode.object
        [ ( "id", Encode.int user.id )
        , ( "username", Encode.string user.username )
        , ( "password", Encode.string user.password )
        , ( "firstname", Encode.string user.firstname )
        , ( "lastname", Encode.string user.lastname )
        , ( "email", Encode.string user.email )
        , ( "payrate", Encode.float user.payrate )
        , ( "authLevel", Encode.int user.authLevel )
        ]

succeed : a -> Decoder a
succeed =
    Decode.succeed


