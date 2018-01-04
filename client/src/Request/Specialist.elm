module Request.Specialist exposing (get, post)

import Http
import Data.Specialist exposing (Specialist, decoder, encoder, manyDecoder)


--get = Http.request
--    Http.request
--        { method = "GET"
--        , headers = []
--        , url = url
--        , body = Http.emptyBody
--        , expect = manyDecoder
--        , timeout = Nothing
--        , withCredentials = False
--        }


get : Http.Request ( List Specialist )
get =
    Http.get "http://localhost:8080/cpss/specialist/list" manyDecoder


post : Specialist -> Http.Request Specialist
post specialist =
    let
        body : Http.Body
        body =
            encoder specialist
                |> Http.jsonBody
    in
        Http.post "http://localhost:8080/cpss/specialist" body decoder


