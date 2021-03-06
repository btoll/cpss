module Data.User exposing
    ( User
    , UserWithPager
    , authEncoder
    , decoder
    , encoder
    , hashEncoder
    , manyDecoder
    , new
    , pagingDecoder
    , queryEncoder
    , succeed
    )


import Data.Pager
import Json.Decode as Decode exposing (Decoder, bool, float, int, list, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode



type alias User =
    { id : Int
    , username : String
    , password : String
    , firstname : String
    , lastname : String
    , active : Bool
    , email : String
    , payrate : Float
    , authLevel : Int
    , loginTime : Int
    , currentTime : Int
    }


type alias UserWithPager =
    { users : List User
    , pager : Data.Pager.Pager
    }


new : User
new =
    { id = -1
    , username = ""
    , password = ""
    , firstname = ""
    , lastname = ""
    , active = True
    , email = ""
    , payrate = 0.00
    , authLevel = -1
    , loginTime = -1
    , currentTime = -1
    }


decoder : Decoder User
decoder =
    decode User
        |> required "id" int
        |> optional "username" string ""
        |> optional "password" string ""
        |> optional "firstname" string ""
        |> optional "lastname" string ""
        |> optional "active" bool True
        |> optional "email" string ""
        |> optional "payrate" float 0.00
        |> optional "authLevel" int 1
        |> optional "loginTime" int 0
        |> optional "currentTime" int 0


manyDecoder : Decoder ( List User )
manyDecoder =
    list decoder


pagingDecoder : Decoder UserWithPager
pagingDecoder =
    decode UserWithPager
        |> required "users" manyDecoder
        |> required "pager" Data.Pager.decoder


authEncoder : { r | username : String, password : String } -> Encode.Value
authEncoder user =
    Encode.object
        [ ( "username", Encode.string user.username )
        , ( "password", Encode.string user.password )
        ]


encoder : User -> Encode.Value
encoder user =
    Encode.object
        [ ( "id", Encode.int user.id )
        , ( "username", Encode.string user.username )
        , ( "password", Encode.string user.password )
        , ( "firstname", Encode.string user.firstname )
        , ( "lastname", Encode.string user.lastname )
        , ( "active", Encode.bool user.active )
        , ( "email", Encode.string user.email )
        , ( "payrate", Encode.float user.payrate )
        , ( "authLevel", Encode.int user.authLevel )
        , ( "loginTime", Encode.int user.loginTime )
        , ( "currentTime", Encode.int user.currentTime )
        ]


hashEncoder : { r | id : Int, password : String } -> Encode.Value
hashEncoder user =
    Encode.object
        [ ( "id", Encode.int user.id )
        , ( "password", Encode.string user.password )
        ]


queryEncoder : String -> Encode.Value
queryEncoder whereClause =
    Encode.object
        [ ( "whereClause", Encode.string whereClause )
        ]


succeed : a -> Decoder a
succeed =
    Decode.succeed


