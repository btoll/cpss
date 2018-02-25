module Request.BillSheet exposing (delete, list, page, post, put)

import Http
import Data.BillSheet exposing (BillSheet, BillSheetWithPager, decoder, encoder, manyDecoder, pagingDecoder, succeed)



delete : String -> BillSheet -> Http.Request Int
delete url billsheet =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/billsheet/" ) ( billsheet.id |> toString )
        , body = Http.emptyBody
        , expect = Http.expectJson ( succeed billsheet.id )
        , timeout = Nothing
        , withCredentials = False
        }


--get : String -> String -> Http.Request BillSheetWithPager
--get url method =
--    pagingDecoder
--        |> Http.get ( url ++ "/billsheet/" ++ method )


list : String -> Http.Request ( List BillSheet )
list url =
    manyDecoder |> Http.get ( (++) url "/billsheet/list" )


page : String -> Int -> Http.Request BillSheetWithPager
page url page =
    pagingDecoder |> Http.get ( url ++ "/billsheet/list/" ++ ( page |> toString ) )


post : String -> BillSheet -> Http.Request BillSheet
post url billsheet =
    let
        body : Http.Body
        body =
            encoder billsheet
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/billsheet/" ) body


put : String -> BillSheet -> Http.Request BillSheet
put url billsheet =
    let
        body : Http.Body
        body =
            encoder billsheet
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/billsheet/" ) ( billsheet.id |> toString ) )
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


