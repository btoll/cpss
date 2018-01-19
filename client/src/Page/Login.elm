--module Page.Login exposing (ExternalMsg(..), Model, Msg, initialModel, update, view)
module Page.Login exposing (ExternalMsg(..), Model, Msg, init, update, view)

import Data.Login as Login exposing (Login)
import Data.Session as Session exposing (Session)
import Data.User as User exposing (User)
import Html exposing (Html, form)
import Html.Attributes
import Html.Events exposing (onSubmit)
import Http
import Request.Login
import Task exposing (Task)
import Util.Form as Form



-- MODEL --


type alias Model =
    Login


init : Login
init =
--    { errors = []
    { username = ""
    , password = ""
    }



-- UPDATE --


type Msg
    = Authenticate
    | Authenticated ( Result Http.Error Login )
    | Cancel
    | SetFormValue ( String -> Model ) String


type ExternalMsg
    = NoOp
    | SetUser User


update : String -> Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update url msg model =
    case msg of
        Authenticate ->
            ( model ! [
                Request.Login.post url model
                    |> Http.toTask
                    |> Task.attempt Authenticated
            ] , NoOp )

        Authenticated ( Ok login ) ->
            ( { model | username = "" , password = "" } ! [], SetUser ( User login.username "" 1 ) )

        Authenticated ( Err err ) ->
            let
                e = (Debug.log "err" err)
            in
            ( { model | username = "" , password = "" } ! [], NoOp )

        Cancel ->
            ( { username = "", password = "" } ! [], NoOp )

        SetFormValue fn s ->
            ( ( s |> fn ) ! [], NoOp )



-- VIEW --


view : Model -> Html Msg
view model =
    form [ onSubmit Authenticate ] [
        Form.textRow "Username" model.username ( SetFormValue (\v -> { model | username = v }) )
        , Form.passwordRow "Password" model.password ( SetFormValue (\v -> { model | password = v }) )
        , Form.submitRow ( (||) ( model.username |> String.isEmpty ) ( model.password |> String.isEmpty ) ) Cancel
    ]


