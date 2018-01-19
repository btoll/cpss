module Request.Login exposing (post)

import Http
import Data.Login exposing (Login, decoder, encoder)



post : String -> Login -> Http.Request Login
post url login =
    let
        body : Http.Body
        body =
            encoder login
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/login/" ) body


