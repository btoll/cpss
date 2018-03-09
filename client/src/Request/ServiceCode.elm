module Request.ServiceCode exposing (delete, list, post, put)

import Http
import Data.ServiceCode exposing (ServiceCode, decoder, encoder, manyDecoder, succeed)



delete : String -> ServiceCode -> Http.Request ServiceCode
delete url serviceCode =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/servicecode/" ) ( toString serviceCode.id )
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


list : String -> Http.Request ( List ServiceCode )
list url =
    manyDecoder
        |> Http.get ( (++) url "/servicecode/list" )


post : String -> ServiceCode -> Http.Request ServiceCode
post url serviceCode =
    let
        body : Http.Body
        body =
            encoder serviceCode
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/servicecode/" ) body


put : String -> ServiceCode -> Http.Request ServiceCode
put url serviceCode =
    let
        body : Http.Body
        body =
            encoder serviceCode
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/servicecode/" ) ( toString serviceCode.id ) )
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


