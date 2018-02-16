module Request.County exposing (list)

import Http
import Data.County exposing (County, manyDecoder)



get : String -> String -> Http.Request ( List County )
get url method =
    manyDecoder
        |> Http.get ( url ++ "/county/" ++ method )


list : String -> Http.Request ( List County )
list url =
    "list"
        |> get url


