module Views.Pager exposing (view)

import Data.Pager exposing (Pager)
import Html exposing (Attribute, Html, button, div, span, text)
import Html.Attributes exposing (class, disabled, style)
import Html.Events exposing (onClick)



navControls : ( Maybe Int -> msg ) -> Int -> Int -> List ( Html msg )
navControls toMsg lastPage currentPage =
    let
        navigation : List ( Int, String, Int )
        navigation =
            {- ( newPage
                , string directional symbol for button
                , page boundary )
            -}
            [ ( 0
                , "<<"
                , 0 )

            , ( 1 |> (-) currentPage
                , "<"
                , 0 )

            , ( 1 |> (+) currentPage
                , ">"
                , 1 |> (-) lastPage )

            , ( 1 |> (-) lastPage
                , ">>"
                , 1 |> (-) lastPage )
            ]

        mapper : ( Int, String, Int ) -> Html msg
        mapper =
            \( newPage, s, boundary ) ->
                let
                    isDisabled =
                        boundary |> (==) currentPage
                in
                button
                    [ isDisabled |> disabled
                    , "pager-nav" |> class
                    , newPage |> Just |> toMsg |> onClick
                    ]
                    [ s |> text ]

    in
    navigation |> List.map mapper


view : ( Maybe Int -> msg ) -> Pager -> Html msg
view toMsg pager =
    if 1 |> (>) pager.totalPages then
        let
            currentPage = pager.currentPage

            nav : List ( Html msg )
            nav =
                currentPage
                    |> navControls toMsg pager.totalPages
        in
        div [ "pager-container" |> class ]
            [ nav
                |> List.drop 2
                |> (::) ( span [ "pager-display" |> class ] [ 1 |> (+) currentPage |> toString |> text ] )       -- Page numbering on the server is zero-based.
                |> (++) ( List.take 2 nav )
                |> div [ "pager-inner" |> class ]
            ]
    else
        div [] []


