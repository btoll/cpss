module Request.BillSheet exposing (delete, list, post, put)

import Http
import Data.BillSheet exposing (BillSheet, decoder, encoder, manyDecoder, succeed)



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


list : String -> Http.Request ( List BillSheet )
list url =
    manyDecoder
        |> Http.get ( (++) url "/billsheet/list" )


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


