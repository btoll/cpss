module Request.Status exposing (delete, list, post, put)

import Http
import Data.Status exposing (Status, decoder, encoder, manyDecoder, succeed)



delete : String -> Status -> Http.Request Status
delete url status =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/status/" ) ( toString status.id )
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


list : String -> Http.Request ( List Status )
list url =
    manyDecoder
        |> Http.get ( (++) url "/status/list" )


post : String -> Status -> Http.Request Status
post url status =
    let
        body : Http.Body
        body =
            encoder status
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/status/" ) body


put : String -> Status -> Http.Request Status
put url status =
    let
        body : Http.Body
        body =
            encoder status
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/status/" ) ( toString status.id ) )
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


