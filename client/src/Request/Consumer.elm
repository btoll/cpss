module Request.Consumer exposing (delete, get, post)

import Http
import Data.Consumer exposing (Consumer, decoder, encoder, manyDecoder, succeed)



delete : String -> Consumer -> Http.Request ()
delete url consumer =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/consumer/" ) consumer.id
        , body = Http.emptyBody
        , expect = Http.expectJson (succeed ())
        , timeout = Nothing
        , withCredentials = False
        }


get : String -> Http.Request ( List Consumer )
get url =
    manyDecoder
        |> Http.get ( (++) url "/consumer/list" )


post : String -> Consumer -> Http.Request Consumer
post url consumer =
    let
        body : Http.Body
        body =
            encoder consumer
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/consumer/" ) body


