module Request.Specialist exposing (delete, get, post, put)

import Http
import Data.User exposing (User, decoder, encoder, manyDecoder, succeed)



delete : String -> User -> Http.Request User
delete url specialist =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/specialist/" ) ( toString specialist.id )
        , body = Http.emptyBody
        , expect = Http.expectJson ( succeed specialist )
        , timeout = Nothing
        , withCredentials = False
        }


get : String -> Http.Request ( List User )
get url =
    manyDecoder
        |> Http.get ( (++) url "/specialist/list" )


post : String -> User -> Http.Request User
post url specialist =
    let
        body : Http.Body
        body =
            encoder specialist
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/specialist/" ) body


put : String -> User -> Http.Request User
put url specialist =
    let
        body : Http.Body
        body =
            encoder specialist
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/specialist/" ) ( toString specialist.id ) )
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


