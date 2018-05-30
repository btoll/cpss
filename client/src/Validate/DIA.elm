module Validate.DIA exposing (errors)

import Data.DIA exposing (DIA)
import Validate.Validate exposing (fold, isBlank)



errors : DIA -> List String
errors model =
    [ isBlank model.name "DIA cannot be blank."
    ]
        |> fold


