module Validate.County exposing (errors)

import Data.County exposing (County)
import Validate.Validate exposing (fold, isSelected)



errors : County -> List String
errors model =
    [ isSelected model.id "Please select a County."
    ]
        |> fold


