module Request.Specialist exposing (delete, get, post)

import Http
import Data.Specialist exposing (Specialist, decoder, encoder, manyDecoder, succeed)



delete : Specialist -> Http.Request ()
delete specialist =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) "http://localhost:8080/cpss/specialist/" specialist.id
        , body = Http.emptyBody
        , expect = Http.expectJson (succeed ())
        , timeout = Nothing
        , withCredentials = False
        }


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
        Http.post "http://localhost:8080/cpss/specialist/" body decoder


