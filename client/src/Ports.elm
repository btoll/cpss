port module Ports exposing
    ( SessionCredentials
    , getSessionCredentials
    , setSessionCredentials
    )



type alias SessionCredentials =
    { sessionName : String
    , expiry : String
    , userID : Int
    , lastLogin : Int
    , currentLogin : Int
    }


port getSessionCredentials : ( SessionCredentials -> msg ) -> Sub msg


port setSessionCredentials : SessionCredentials -> Cmd msg


