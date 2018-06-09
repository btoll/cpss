module Page.Home exposing (view)

import Html exposing (Html, div, form, h1, text)
import Html.Attributes exposing (autofocus, value)
import Html.Events exposing (onInput, onSubmit)



-- MODEL --


--type alias Model =
--    { username : String
--    , password : String
--    }
--
--
--init : Model
--init =
--    { username = ""
--    , password = ""
--    }



-- UPDATE --


--type Msg
--    = Authenticate
--    | Authenticated ( Result Http.Error User )
--    | Cancel
--    | SetFormValue ( String -> Model ) String
--
--
--type ExternalMsg
--    = NoOp
--    | SetUser User
--
--
--update : String -> Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
--update url msg model =
--    case msg of
--        Authenticate ->
--            ( model ! [
--                Request.Session.auth url model
--                    |> Http.toTask
--                    |> Task.attempt Authenticated
--            ] , NoOp )
--
--        Authenticated ( Ok user ) ->
--            ( { model | username = "" , password = "" } ! [], SetUser user )
--
--        Authenticated ( Err err ) ->
--            ( { model | username = "", password = "" } ! [], NoOp )
--
--        Cancel ->
--            ( { model | username = "", password = "" } ! [], NoOp )
--
--        SetFormValue fn s ->
--            ( ( s |> fn ) ! [], NoOp )
--


-- VIEW --


view : Html msg
view =
    div []
        [ h1 [] [ "CPSS" |> text ]
    ]


