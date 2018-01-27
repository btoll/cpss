module Page.Login exposing (ExternalMsg(..), Model, Msg, init, update, view)

import Data.Session as Session exposing (Session)
import Data.User as User exposing (User)
import Html exposing (Html, form)
import Html.Attributes
import Html.Events exposing (onSubmit)
import Http
import Request.Session
import Task exposing (Task)
import Util.Form as Form



-- MODEL --


type alias Model =
    { errors : List String
    , username : String
    , password : String
    }


init : Model
init =
    { errors = []
    , username = ""
    , password = ""
    }



-- UPDATE --


type Msg
    = Authenticate
    | Authenticated ( Result Http.Error User )
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
                Request.Session.auth url model
                    |> Http.toTask
                    |> Task.attempt Authenticated
            ] , NoOp )

        Authenticated ( Ok user ) ->
            ( { model | username = "" , password = "" } ! [], SetUser user )

        Authenticated ( Err err ) ->
            let
                e = (Debug.log "err" err)
            in
            ( { model | username = "", password = "" } ! [], NoOp )

        Cancel ->
            ( { model | username = "", password = "" } ! [], NoOp )

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


