--module Page.Login exposing (ExternalMsg(..), Model, Msg, initialModel, update, view)
module Page.Login exposing (ExternalMsg(..), Model, Msg, init, update, view)

import Data.Session as Session exposing (Session)
import Data.User as User exposing (User)
import Html exposing (Html, form)
import Html.Attributes
import Html.Events exposing (onSubmit)
import Http
import Util.Form as Form
--import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
--import Json.Decode.Pipeline as Pipeline exposing (decode, optional)
--import Request.User exposing (storeSession)
--import Route exposing (Route)
--import Util exposing ((=>))
--import Validate exposing (..)
--import Views.Form as Form



-- MODEL --


type alias Model =
--    { errors : List Error
    { username : String
    , password : String
    }


init : Model
init =
--    { errors = []
    { username = ""
    , password = ""
    }



-- UPDATE --


type Msg
    = Authenticate User
    | Cancel
    | SetFormValue ( String -> Model ) String
--    | LoginCompleted (Result Http.Error User)


type ExternalMsg
    = NoOp
    | SetUser User


update : String -> Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update url msg model =
    case msg of
        Authenticate user ->
            ( model ! [], SetUser user )

        Cancel ->
            ( { username = "", password = "" } ! [], NoOp )

        SetFormValue fn s ->
            ( ( s |> fn ) ! [], NoOp )



-- VIEW --


view : Model -> Html Msg
view model =
    form [ onSubmit ( Authenticate ( User model.username "foo@example.com" "" "" ) ) ] [
        Form.textRow "Username" model.username ( SetFormValue (\v -> { model | username = v }) )
        , Form.passwordRow "Password" model.password ( SetFormValue (\v -> { model | password = v }) )
        , Form.submitRow ( (||) ( model.username |> String.isEmpty ) ( model.password |> String.isEmpty ) ) Cancel
    ]


