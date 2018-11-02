module Request.County exposing (delete, get, list, page, post, put)

import Http
import Data.County exposing
    (County
    , CountyWithPager
    , decoder
    , encoder
    , manyDecoder
    , pagingDecoder
    , succeed
    )



delete : String -> County -> Http.Request Int
delete url county =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/county/" ) ( county.id |> toString )
        , body = Http.emptyBody
        , expect = Http.expectJson ( succeed county.id )
        , timeout = Nothing
        , withCredentials = False
        }


get : String -> String -> Http.Request ( List County )
get url method =
    manyDecoder
        |> Http.get ( url ++ "/county/" ++ method )


list : String -> Http.Request ( List County )
list url =
    manyDecoder |> Http.get ( (++) url "/county/list" )


page : String -> Int -> Http.Request CountyWithPager
page url page =
    pagingDecoder |> Http.get ( url ++ "/county/list/" ++ ( page |> toString ) )


post : String -> County -> Http.Request County
post url county =
    let
        body : Http.Body
        body =
            encoder county
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/county/" ) body


put : String -> County -> Http.Request County
put url county =
    let
        body : Http.Body
        body =
            encoder county
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/county/" ) ( county.id |> toString ) )
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


