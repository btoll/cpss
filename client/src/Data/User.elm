module Data.User exposing (User)


type alias User =
--    { username : Username
    { username : String
--    , token : AuthToken
    , email : String
--    , bio : Maybe String
--    , image : UserPhoto
    , createdAt : String
    , updatedAt : String
    }


type Username =
    String


