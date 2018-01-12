module Request.BillSheet exposing (delete, get, post)

import Http
import Data.BillSheet exposing (BillSheet, decoder, encoder, manyDecoder, succeed)



delete : String -> BillSheet -> Http.Request ()
delete url billsheet =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/billsheet/" ) billsheet.id
        , body = Http.emptyBody
        , expect = Http.expectJson (succeed ())
        , timeout = Nothing
        , withCredentials = False
        }


get : String -> Http.Request ( List BillSheet )
get url =
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


