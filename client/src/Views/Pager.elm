module Views.Pager exposing (Msg, update, view)

import Html exposing (Attribute, Html, button, div, span, text)
import Html.Attributes exposing (disabled, style)
import Html.Events exposing (onClick)



type Msg
    = First
    | Prev
    | Next
    | Last



update : ( Int, Int ) -> Msg -> Int
update ( currentPage, totalPages ) msg =
    case msg of
        First ->
            0

        Prev ->
            1 |> (-) currentPage

        Next ->
            1 |> (+) currentPage

        Last ->
            1 |> (-) totalPages



-- VIEW


containerCss : Attribute Msg
containerCss =
    style
    [
    ( "background", "#ccc" )
    , ( "border", "1px solid #aaa" )
    , ( "margin", "2em" )
    , ( "padding", ".5em 0" )
    , ( "width", "12em" )
    ]


displayCss : Attribute Msg
displayCss =
    style
    [ ( "display", "inline-block" )
    , ( "width", "2.5em" )
    ]


innerCss : Attribute Msg
innerCss =
    style
    [ ( "text-align", "center" )
    ]


navCss : Attribute Msg
navCss =
    style
    [ ( "display", "inline-block" )
    , ( "margin", "0 .2em" )
    ]



navControls : Int -> Int -> List ( Html Msg )
navControls lastPage currentPage =
    let
        navigation : List ( Msg, String, Int )
        navigation =
            [ ( First, "<<", 0 )
            , ( Prev, "<", 0 )
            , ( Next, ">", 1 |> (-) lastPage )
            , ( Last, ">>", 1 |> (-) lastPage )
            ]

        mapper =
            \( msg, s, boundary ) ->
                let
                    isDisabled =
                        boundary |> (==) currentPage
                in
                button [ disabled isDisabled, navCss, onClick msg ] [ text s ]

    in
    navigation |> List.map mapper


view : Int -> Int -> Html Msg
view lastPage currentPage =
    let
        nav : List ( Html Msg )
        nav =
            currentPage
                |> navControls lastPage
    in
    div [ containerCss ]
        [ nav
            |> List.drop 2
            |> (::) ( span [ displayCss ] [ 1 |> (+) currentPage |> toString |> text ] )       -- Page numbering on the server is zero-based.
            |> (++) ( List.take 2 nav )
            |> div [ innerCss ]
        ]


