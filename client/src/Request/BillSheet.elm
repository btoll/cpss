module Request.BillSheet exposing (delete, get, post)

import Http
import Data.BillSheet exposing (BillSheet, decoder, encoder, manyDecoder, succeed)



delete : BillSheet -> Http.Request ()
delete billsheet =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) "http://localhost:8080/cpss/billsheet/" billsheet.id
        , body = Http.emptyBody
        , expect = Http.expectJson (succeed ())
        , timeout = Nothing
        , withCredentials = False
        }


get : Http.Request ( List BillSheet )
get =
    Http.get "http://localhost:8080/cpss/billsheet/list" manyDecoder


post : BillSheet -> Http.Request BillSheet
post billsheet =
    let
        body : Http.Body
        body =
            encoder billsheet
                |> Http.jsonBody
    in
        Http.post "http://localhost:8080/cpss/billsheet/" body decoder


