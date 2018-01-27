module Request.Session exposing (auth, hash)

import Http
import Data.User exposing (User, decoder, authEncoder, hashEncoder)
import Json.Encode as Encode



post : String -> ( a -> Encode.Value ) -> String -> a -> Http.Request User
post method encoder url user =
    let
        body : Http.Body
        body =
            encoder user
                |> Http.jsonBody
    in
        decoder
            |> Http.post ( (++) url ( (++) "/session/" method ) ) body


-- We're not defining an `Auth` type here b/c the Login page (the main caller of this function)
-- also has an `errors` field in its model!
auth : String -> { r | username : String, password : String } -> Http.Request User
auth =
    post "auth" authEncoder


-- Same reasoning as above, but for the Specialist page!
hash : String -> { r | id : Int, password : String } -> Http.Request User
hash =
    post "hash" hashEncoder


