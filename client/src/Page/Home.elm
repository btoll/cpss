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
            [ div [ "buttons" |> class ]
                [ button [ editable |> ChangePassword |> onClick ] [ text "Change Password" ]
                ]
                , p [] [ "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque nulla erat, vulputate non turpis at, egestas pellentesque metus. Nulla sit amet urna at risus tristique tempor a at nisi. Aenean ullamcorper quam in ante auctor, eu volutpat libero rutrum. Suspendisse sollicitudin tellus in sapien vehicula, consequat condimentum nibh fringilla. Cras vitae risus quis dui malesuada rhoncus. Nullam sed sapien sit amet diam placerat vestibulum et semper nisl. Curabitur vel eros rutrum, porttitor risus nec, aliquet augue. In non justo sapien. Nunc tempus, odio ut molestie luctus, mauris augue laoreet diam, et tempor lorem libero non justo. Aenean sed finibus dui. Donec pellentesque risus lorem, id cursus nulla tristique in." |> text ]
                , p [] [ "Duis nec pulvinar nulla. Donec dignissim ante a odio ullamcorper porttitor. Maecenas pellentesque purus ut neque elementum, vitae tempus tortor maximus. Donec imperdiet orci magna, a vehicula nibh condimentum tempor. Morbi id quam a justo fringilla imperdiet tincidunt vel ligula. Nullam ac odio in lacus pulvinar mattis eget in tellus. Quisque in eleifend massa." |> text ]
                , p [] [ "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nunc imperdiet sit amet erat ut tempor. Aenean neque leo, malesuada in ipsum nec, iaculis condimentum eros. Donec id rhoncus metus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam faucibus pellentesque justo, ullamcorper fermentum massa feugiat ut. Morbi vitae aliquam diam. In sagittis pretium mollis. Phasellus ut mauris suscipit, vestibulum nisi sit amet, hendrerit leo. Praesent porta, velit sit amet fermentum consectetur, orci justo molestie velit, in consequat quam sem non arcu." |> text ]
                , p [] [ "Aliquam bibendum, tortor vitae condimentum mollis, augue elit placerat justo, et tincidunt lectus ligula quis quam. Suspendisse mollis a tellus at finibus. Maecenas tortor dolor, consectetur vel massa ac, consequat iaculis enim. Fusce erat metus, pellentesque eu porta id, eleifend eget est. Aliquam scelerisque sed justo et tristique. Nulla sit amet metus sem. Nullam ut sodales ex, nec fermentum risus. In id cursus odio. Etiam odio massa, placerat eget mauris et, tincidunt efficitur felis. Suspendisse potenti." |> text ]
                , p [] [ "Cras rutrum consequat lectus vel vulputate. Vestibulum et diam feugiat eros porta pellentesque. Sed tellus nibh, blandit cursus augue dictum, pretium rhoncus justo. Donec nec feugiat urna. Donec blandit nibh eget imperdiet lacinia. Mauris in odio nec augue porttitor dignissim. Proin vestibulum nisl a ipsum mollis, eget aliquam est posuere. Nullam ultrices a felis ut pellentesque." |> text ]
                , p [] [ "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque nulla erat, vulputate non turpis at, egestas pellentesque metus. Nulla sit amet urna at risus tristique tempor a at nisi. Aenean ullamcorper quam in ante auctor, eu volutpat libero rutrum. Suspendisse sollicitudin tellus in sapien vehicula, consequat condimentum nibh fringilla. Cras vitae risus quis dui malesuada rhoncus. Nullam sed sapien sit amet diam placerat vestibulum et semper nisl. Curabitur vel eros rutrum, porttitor risus nec, aliquet augue. In non justo sapien. Nunc tempus, odio ut molestie luctus, mauris augue laoreet diam, et tempor lorem libero non justo. Aenean sed finibus dui. Donec pellentesque risus lorem, id cursus nulla tristique in." |> text ]
                , p [] [ "Duis nec pulvinar nulla. Donec dignissim ante a odio ullamcorper porttitor. Maecenas pellentesque purus ut neque elementum, vitae tempus tortor maximus. Donec imperdiet orci magna, a vehicula nibh condimentum tempor. Morbi id quam a justo fringilla imperdiet tincidunt vel ligula. Nullam ac odio in lacus pulvinar mattis eget in tellus. Quisque in eleifend massa." |> text ]
                , p [] [ "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nunc imperdiet sit amet erat ut tempor. Aenean neque leo, malesuada in ipsum nec, iaculis condimentum eros. Donec id rhoncus metus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam faucibus pellentesque justo, ullamcorper fermentum massa feugiat ut. Morbi vitae aliquam diam. In sagittis pretium mollis. Phasellus ut mauris suscipit, vestibulum nisi sit amet, hendrerit leo. Praesent porta, velit sit amet fermentum consectetur, orci justo molestie velit, in consequat quam sem non arcu." |> text ]
                , p [] [ "Aliquam bibendum, tortor vitae condimentum mollis, augue elit placerat justo, et tincidunt lectus ligula quis quam. Suspendisse mollis a tellus at finibus. Maecenas tortor dolor, consectetur vel massa ac, consequat iaculis enim. Fusce erat metus, pellentesque eu porta id, eleifend eget est. Aliquam scelerisque sed justo et tristique. Nulla sit amet metus sem. Nullam ut sodales ex, nec fermentum risus. In id cursus odio. Etiam odio massa, placerat eget mauris et, tincidunt efficitur felis. Suspendisse potenti." |> text ]
                , p [] [ "Cras rutrum consequat lectus vel vulputate. Vestibulum et diam feugiat eros porta pellentesque. Sed tellus nibh, blandit cursus augue dictum, pretium rhoncus justo. Donec nec feugiat urna. Donec blandit nibh eget imperdiet lacinia. Mauris in odio nec augue porttitor dignissim. Proin vestibulum nisl a ipsum mollis, eget aliquam est posuere. Nullam ultrices a felis ut pellentesque." |> text ]
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


