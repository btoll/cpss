module Views.Form exposing (
    Selection(..)
    , checkbox
    , float
    , option
    , password
    , select
    , submit
    , text
    , textarea
    , toFloat
    , toInt
    )


import Html exposing (Html, Attribute, div, input, label)
import Html.Attributes exposing (disabled, for, id, selected, step, type_, value)
import Html.Events exposing (onClick, onInput)



type Selection
    = ConsumerID
    | CountyID
    | DIAID
    | FundingSourceID
    | ServiceCodeID
    | SpecialistID
    | StatusID
    | ZipID



control :
    String ->
    ( List ( Attribute msg ) -> List ( Html msg ) -> Html msg ) ->
    List ( Attribute msg ) ->
    List ( Html msg ) ->
    Html msg
control name element attrs children =
    div [] [
        label [ prepareId name |> for ] [ Html.text name ]
        , element attrs children
    ]


inputControl : String -> String -> List ( Attribute msg ) -> List ( Html msg ) -> Html msg
inputControl inputType name attrs =
    control name input ( [ type_ inputType ] ++ attrs )


checkbox : String -> List ( Attribute msg ) -> List ( Html msg ) -> Html msg
checkbox name attrs =
    inputControl "checkbox" name attrs


float : String -> List ( Attribute msg ) -> List ( Html msg ) -> Html msg
float name attrs =
    inputControl "number" name ( attrs |> (::) ( step "0.01" ) )


-- TODO: The compiler doesn't like this annotation!
--option : String -> String -> ( String, String ) -> List ( Attribute msg ) -> List ( Html msg ) -> Html msg
option selectedOption ( val, txt ) =
    Html.option [ selected ( (==) val selectedOption ), value val ] [ Html.text txt ]


password : String -> List ( Attribute msg ) -> List ( Html msg ) -> Html msg
password name attrs =
    inputControl "password" name attrs


-- Remove any spaces in name (`id` attr doesn't allow for spaces).
prepareId : String -> String
prepareId name =
    name
        |> String.words
        |> String.concat


select : String -> List ( Attribute msg ) -> List ( Html msg ) -> Html msg
select name attrs =
    control name Html.select attrs


-- Is it worth abstracting this?
submit : Bool -> msg -> Html msg
submit isDisabled toMsg =
    div [] [
        input [ disabled isDisabled, type_ "submit" ] []
        , input [ onClick toMsg, type_ "button", value "Cancel" ] []
    ]


text : String -> List ( Attribute msg ) -> List ( Html msg ) -> Html msg
text name attrs =
    inputControl "text" name attrs


textarea : String -> List ( Attribute msg ) -> List ( Html msg ) -> Html msg
textarea name attrs =
    control name Html.textarea attrs


toFloat : String -> Float
toFloat v =
    String.toFloat v
        |> Result.withDefault 0.00


toInt : String -> Int
toInt v =
    String.toInt v
        |> Result.withDefault 0


