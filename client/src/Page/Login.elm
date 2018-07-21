module Page.Login exposing (ExternalMsg(..), Model, Msg, init, update, view)

import Data.Session as Session exposing (Session)
import Data.User as User exposing (User)
import Html exposing (Html, div, form, h1, p, text)
import Html.Attributes exposing (autofocus, class, src, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Request.Session
import Task exposing (Task)
import Views.Form as Form



-- MODEL --


type alias Model =
    { username : String
    , password : String
    , error : String
    }


init : Model
init =
    { username = ""
    , password = ""
    , error = ""
    }



-- UPDATE --


type Msg
    = Authenticate
    | Authenticated ( Result Http.Error User )
    | Cancel
    | SetFormValue ( String -> Model ) String


type ExternalMsg
    = Nop
    | SetUser User


update : String -> Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update url msg model =
    case msg of
        Authenticate ->
            ( model ! [
                Request.Session.auth url model
                    |> Http.toTask
                    |> Task.attempt Authenticated
            ] , Nop )

        Authenticated ( Ok user ) ->
            ( { model | username = "" , password = "", error = "" } ! [], SetUser user )

        Authenticated ( Err err ) ->
            ( { model | username = "", password = "", error = "Bad username or password" } ! [], Nop )

        Cancel ->
            ( { model | username = "", password = "" , error = ""} ! [], Nop )

        SetFormValue fn s ->
            ( ( s |> fn ) ! [], Nop )



-- VIEW --


view : Model -> Html Msg
view model =
    let
        cls =
            if model.error |> (==) ""
            then "hide error"
            else "error"
    in
    div []
        [ div [ cls |> class ] [ model.error |> text ]
        , div []
            [ h1 [] [ "Central Pennsylvania Supportive Services, Inc. (CPSS)" |> text ]
            , form [ onSubmit Authenticate ] [
                Form.text "Username"
                    [ value model.username
                    , onInput ( SetFormValue ( \v -> { model | username = v } ) )
                    , autofocus True
                    ]
                    []
                , Form.password "Password"
                    [ value model.password
                    , onInput ( SetFormValue ( \v -> { model | password = v } ) )
                    ]
                    []
               , Form.submit
                   ( (||)
                       ( model.username |> String.isEmpty )
                       ( model.password |> String.isEmpty )
                   )
                   Cancel
            ]
        ]
    ]


