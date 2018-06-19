module Request.PayHistory exposing (list)

import Http
import Data.PayHistory exposing (PayHistory, decoder, manyDecoder)



list : String -> Int -> Http.Request ( List PayHistory )
list url specialist =
    manyDecoder
        |> Http.get
        (
            (++) url
            (
                (++) "/payhistory/"
                ( specialist |> toString )
            )
        )


