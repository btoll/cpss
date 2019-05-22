--module Data.Session exposing (Session, attempt)
module Data.Session exposing (Session)

--import Data.AuthToken exposing (AuthToken)
import Data.User as User exposing (User)
--import Util exposing ((=>))
import Date exposing (Date)



type alias Session =
    { user : Maybe User
    , sessionName : String
    , expiry : String
    , lastLogin : Int
    , currentLogin : Int
    }


--attempt : String -> (AuthToken -> Cmd msg) -> Session -> ( List String, Cmd msg )
--attempt attemptedAction toCmd session =
--    case Maybe.map .token session.user of
--        Nothing ->
--            [ "You have been signed out. Please sign back in to " ++ attemptedAction ++ "." ] => Cmd.none
--
--        Just token ->
--            [] => toCmd token


