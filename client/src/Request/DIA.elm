module Request.DIA exposing (delete, list, post, put)

import Http
import Data.DIA exposing (DIA, decoder, encoder, manyDecoder, succeed)



delete : String -> DIA -> Http.Request DIA
delete url dia =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/dia/" ) ( toString dia.id )
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


list : String -> Http.Request ( List DIA )
list url =
    manyDecoder
        |> Http.get ( (++) url "/dia/list" )


post : String -> DIA -> Http.Request DIA
post url dia =
    let
        body : Http.Body
        body =
            encoder dia
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/dia/" ) body


put : String -> DIA -> Http.Request DIA
put url dia =
    let
        body : Http.Body
        body =
            encoder dia
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/dia/" ) ( toString dia.id ) )
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


