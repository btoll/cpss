module Request.Session exposing (auth, hash)

import Http
import Data.User exposing (User, decoder, encoder)



post : String -> String -> User -> Http.Request User
post method url session =
    let
        body : Http.Body
        body =
            encoder session
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url ( (++) "/session/" method ) ) body


auth : String -> User -> Http.Request User
auth =
    post "auth"


hash : String -> User -> Http.Request User
hash =
    post "hash"


