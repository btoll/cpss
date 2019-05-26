port module Ports exposing
    ( SessionCredentials
    , getSessionCredentials
    , setSessionCredentials
    )



type alias SessionCredentials =
    { user : Int
    }


port getSessionCredentials : ( SessionCredentials -> msg ) -> Sub msg


port setSessionCredentials : SessionCredentials -> Cmd msg


