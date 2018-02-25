module Request.Consumer exposing (delete, list, page, post, put)

import Http
import Data.Consumer exposing (Consumer, ConsumerWithPager, decoder, encoder, manyDecoder, pagingDecoder, succeed)



delete : String -> Consumer -> Http.Request Int
delete url consumer =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/consumer/" ) ( consumer.id |> toString )
        , body = Http.emptyBody
        , expect = Http.expectJson ( succeed consumer.id )
        , timeout = Nothing
        , withCredentials = False
        }


list : String -> Http.Request ( List Consumer )
list url =
    manyDecoder |> Http.get ( (++) url "/consumer/list" )


page : String -> Int -> Http.Request ConsumerWithPager
page url page =
    pagingDecoder |> Http.get ( url ++ "/consumer/list/" ++ ( page |> toString ) )


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


put : String -> Consumer -> Http.Request Consumer
put url consumer =
    let
        body : Http.Body
        body =
            encoder consumer
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/consumer/" ) ( consumer.id |> toString ) )
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


