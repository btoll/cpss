module Request.Login exposing (post)

import Http
import Data.User exposing (User, decoder, encoder)



post : String -> User -> Http.Request User
post url login =
    let
        body : Http.Body
        body =
            encoder login
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url "/login/" ) body


