module Request.Specialist exposing (delete, get, list, page, post, put)

import Http
import Data.User exposing (User, UserWithPager, decoder, encoder, manyDecoder, pagingDecoder, succeed)



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


get : String -> String -> Http.Request User
get url specialistID =
    decoder
        |> Http.get ( url ++ "/specialist/" ++ specialistID )


list : String -> Http.Request ( List User )
list url =
    manyDecoder |> Http.get ( (++) url "/specialist/list" )


page : String -> Int -> Http.Request UserWithPager
page url page =
    pagingDecoder |> Http.get ( url ++ "/specialist/list/" ++ ( page |> toString ) )


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


