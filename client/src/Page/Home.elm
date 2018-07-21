module Page.Home exposing (Model, Msg, init, update, view)

import Data.User as User exposing (User, new)
import Html exposing (Html, button, div, form, h1, p, section, text)
import Html.Attributes exposing (autofocus, class, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Request.Session
import Request.Specialist
import Task exposing (Task)
import Views.Errors as Errors
import Views.Form as Form
import Views.Page exposing (ViewAction(..), pageTitle)



-- MODEL --


type alias Model =
    { action : ViewAction
    , disabled : Bool
    , errors : List String
    , newPassword : String
    , confirmPassword : String
    , specialist : Maybe User
    }


init : Maybe User -> ( Model, Cmd Msg )
init specialist =
    { action = None
    , disabled = True
    , errors = []
    , newPassword = ""
    , confirmPassword = ""
    , specialist =
        Just
        << Maybe.withDefault new
        <| specialist
    } ! []



-- UPDATE --


type Msg
    = Cancel
    | ChangePassword User
    | Hashed ( Result Http.Error User )
    | Put ViewAction
    | Putted ( Result Http.Error User )
    | SetPasswordValue ( String -> Model ) String



update : String -> Msg -> Model -> ( Model, Cmd Msg )
update url msg model =
    case msg of
        Cancel ->
            { model |
                action = None
                , newPassword = ""
                , confirmPassword = ""
                , specialist = Nothing
                , errors = []
            } ! []

        ChangePassword specialist ->
            { model |
                action = specialist |> ChangingPassword
                , specialist = specialist |> Just
            } ! []

        Hashed ( Ok specialist ) ->
            let
                newSpecialist =
                    case model.specialist of
                        Nothing ->
                            specialist

                        Just current ->
                            { current | password = specialist.password }

                subCmd =
                    Request.Specialist.put url newSpecialist
                        |> Http.toTask
                        |> Task.attempt Putted
            in
                { model |
                    action = None
                } ! [ subCmd ]

        Hashed ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                action = None
                , errors = (::) e model.errors
            } ! []

        Put action ->
            case action of
                ChangingPassword specialist ->
                    let
                        subCmd =
                            { specialist | password = model.newPassword }
                                |> Request.Session.hash url
                                    |> Http.toTask
                                    |> Task.attempt Hashed
                    in
                        { model |
                            action = None
                            , disabled = True
                            , newPassword = ""
                            , confirmPassword = ""
                        } ! [ subCmd ]

                _ ->
                    model ! []

        Putted ( Ok specialist ) ->
            { model |
                specialist = specialist |> Just
            } ! []

        Putted ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                specialist = Nothing
                , errors = (::) e model.errors
            } ! []

        SetPasswordValue setPasswordValue s ->
            let
                m =
                    s |> setPasswordValue

                passwordsMatch : Bool
                passwordsMatch =
                    if (
                        -- Only enable button if both passwords aren't an empty string AND they match!
                        (
                            ( (==) "" m.confirmPassword ) &&
                            ( (==) "" m.newPassword )
                        ) ||
                            (/=) m.newPassword m.confirmPassword
                        )
                    then True
                    else False
            in
            { m | disabled = passwordsMatch } ! []



-- VIEW --


view : Model -> Html Msg
view model =
    section []
        ( (++)
            [ h1 [] [ "Home" |> pageTitle model.action |> text ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView (
    { action
    , disabled
    , specialist
    } as model ) =
    let
        editable : User
        editable = case specialist of
            Nothing ->
                new

            Just specialist ->
                specialist
    in
    case action of
        None ->
            [ div [] [
                div [ "buttons" |> class ]
                    [ button [ editable |> ChangePassword |> onClick ] [ text "Change Password" ]
                    ]
                , div []
                    [ h1 [] [ "Central Pennsylvania Supportive Services, Inc. (CPSS)" |> text ]
                    , div []
                        [ p [] [ "Guiding People with Challenges to a Life of Independence." |> text ]
                        , p [] [ "Vocational and Living Skills for People with Disabilities." |> text ]
                        , p [] [ "Mission is to guide and support consumers with physical, mental and emotional challenges so they may enjoy a fulfilling life of independence and dignity." |> text ]
                        ]
                    ]
                ]
            ]

        ChangingPassword specialist ->
            [ form [ onSubmit ( Put ( ChangingPassword specialist ) ) ]
                [ Form.password "New Password"
                    [ value model.newPassword
                    , True |> autofocus
                    , onInput ( SetPasswordValue (\v -> { model | newPassword = v } ) )
                    ]
                    []
                , Form.password "Confirm Password"
                    [ value model.confirmPassword
                    , onInput ( SetPasswordValue (\v -> { model | confirmPassword = v } ) )
                    ]
                    []
                , Form.submit disabled Cancel
                ]
            ]

        _ ->
            [ div [] []
            ]


