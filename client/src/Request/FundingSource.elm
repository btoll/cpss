module Request.FundingSource exposing (delete, list, post, put)

import Http
import Data.FundingSource exposing (FundingSource, decoder, encoder, manyDecoder, succeed)



delete : String -> FundingSource -> Http.Request FundingSource
delete url fundingSource =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/fundingsource/" ) ( toString fundingSource.id )
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


list : String -> Http.Request ( List FundingSource )
list url =
    manyDecoder
        |> Http.get ( (++) url "/fundingsource/list" )


post : String -> FundingSource -> Http.Request FundingSource
post url fundingSource =
    let
        body : Http.Body
        body =
            encoder fundingSource
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/fundingsource/" ) body


put : String -> FundingSource -> Http.Request FundingSource
put url fundingSource =
    let
        body : Http.Body
        body =
            encoder fundingSource
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/fundingsource/" ) ( toString fundingSource.id ) )
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


