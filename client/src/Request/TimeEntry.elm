module Request.TimeEntry exposing (delete, list, page, post, put)

import Http
import Data.TimeEntry exposing (TimeEntry, TimeEntryWithPager, decoder, encoder, manyDecoder, pagingDecoder, succeed)



delete : String -> TimeEntry -> Http.Request Int
delete url timeEntry =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = (++) ( (++) url "/timeentry/" ) ( timeEntry.id |> toString )
        , body = Http.emptyBody
        , expect = Http.expectJson ( succeed timeEntry.id )
        , timeout = Nothing
        , withCredentials = False
        }


list : String -> Http.Request ( List TimeEntry )
list url =
    manyDecoder |> Http.get ( (++) url "/timeentry/list" )


page : String -> Int -> Http.Request TimeEntryWithPager
page url page =
    pagingDecoder |> Http.get ( url ++ "/timeentry/list/" ++ ( page |> toString ) )


post : String -> TimeEntry -> Http.Request TimeEntry
post url timeEntry =
    let
        body : Http.Body
        body =
            encoder timeEntry
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/timeentry/" ) body


put : String -> TimeEntry -> Http.Request TimeEntry
put url timeEntry =
    let
        body : Http.Body
        body =
            encoder timeEntry
                |> Http.jsonBody
    in
        Http.request
            { method = "PUT"
            , headers = []
            , url = ( (++) ( (++) url "/timeentry/" ) ( timeEntry.id |> toString ) )
            , body = body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


