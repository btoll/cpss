module Request.County exposing (cities, list)

import Http
import Data.County exposing (City, County, manyDecoder)



get : String -> String -> Http.Request ( List County )
get url method =
    manyDecoder
        |> Http.get ( url ++ "/county/" ++ method )


cities : String -> String -> Http.Request ( List City )
cities url countyID =
    countyID
        |> (++) "city/"
        |> get url


list : String -> Http.Request ( List County )
list url =
    "list"
        |> get url


