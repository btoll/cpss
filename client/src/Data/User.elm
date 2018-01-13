module Data.User exposing (User)


type alias User =
--    { username : Username
    { username : String
    , email : String
    , authLevel : Int
--    , token : AuthToken
--    , bio : Maybe String
--    , image : UserPhoto
--    , createdAt : String
--    , updatedAt : String
    }


type Username =
    String


