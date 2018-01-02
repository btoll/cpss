module Request.Specialist exposing (..)

import Http
import Data.Specialist exposing (Specialist, manyDecoder)


--get = Http.request
--    Http.request
--        { method = "GET"
--        , headers = []
--        , url = url
--        , body = Http.emptyBody
--        , expect = manyDecoder
--        , timeout = Nothing
--        , withCredentials = False
--        }


get : Http.Request ( List Specialist )
get =
    Http.get "http://localhost:8080/cpss/specialist/list" manyDecoder


