module Validate.ServiceCode exposing (errors)

import Data.ServiceCode exposing (ServiceCode)
import Validate.Validate exposing (fold, isBlank)



errors : ServiceCode -> List String
errors model =
    [ isBlank model.name "Service Code cannot be blank."
    ]
        |> fold


