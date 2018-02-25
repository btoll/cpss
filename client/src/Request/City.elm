module Request.City exposing (delete, get, list, page, post, put)

import Http
import Data.City exposing (City, CityWithPager, decoder, encoder, manyDecoder, pagingDecoder, succeed)



delete : String -> City -> Http.Request Int
delete url city =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/city/" ) ( city.id |> toString )
        , body = Http.emptyBody
        , expect = Http.expectJson ( succeed city.id )
        , timeout = Nothing
        , withCredentials = False
        }


get : String -> String -> Http.Request ( List City )
get url method =
    manyDecoder
        |> Http.get ( url ++ "/city/" ++ method )


list : String -> Http.Request ( List City )
list url =
    manyDecoder |> Http.get ( (++) url "/city/list" )


page : String -> Int -> Http.Request CityWithPager
page url page =
    pagingDecoder |> Http.get ( url ++ "/city/list/" ++ ( page |> toString ) )


post : String -> City -> Http.Request City
post url city =
    let
        body : Http.Body
        body =
            encoder city
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/city/" ) body


put : String -> City -> Http.Request City
put url city =
    let
        body : Http.Body
        body =
            encoder city
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/city/" ) ( city.id |> toString ) )
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


