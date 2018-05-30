module Validate.Status exposing (errors)

import Data.Status exposing (Status)
import Validate.Validate exposing (fold, isBlank)



errors : Status -> List String
errors model =
    [ isBlank model.name "Status cannot be blank."
    ]
        |> fold


