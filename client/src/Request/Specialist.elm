module Request.Specialist exposing (delete, get, post)

import Http
import Data.Specialist exposing (Specialist, decoder, encoder, manyDecoder, succeed)



delete : String -> Specialist -> Http.Request ()
delete url specialist =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/specialist/" ) ( toString specialist.id )
        , body = Http.emptyBody
        , expect = Http.expectJson (succeed ())
        , timeout = Nothing
        , withCredentials = False
        }


get : String -> Http.Request ( List Specialist )
get url =
    manyDecoder
        |> Http.get ( (++) url "/specialist/list" )


post : String -> Specialist -> Http.Request Specialist
post url specialist =
    let
        body : Http.Body
        body =
            encoder specialist
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/specialist/" ) body


