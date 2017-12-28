module Main exposing (..)

import Html exposing (..)


-- MODEL

type alias Model = {}
--    { session : Session
--    , pageState : PageState
--    }


-- UPDATE

type Msg
    = Derp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    div [] []


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }

