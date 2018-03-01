port module Ports exposing (SessionCredentials, getSessionCredentials, setSessionCredentials)



--type alias FileData =
--    { contents : String
--    , filename : String
--    }
--
--
--port fileSelected : String -> Cmd msg
--
--
--port fileContentRead : ( List FileData -> msg ) -> Sub msg


type alias SessionCredentials =
    { sessionName : String
    , expiry : String
    , userID : String
    }


port getSessionCredentials : ( SessionCredentials -> msg ) -> Sub msg


port setSessionCredentials : SessionCredentials -> Cmd msg


