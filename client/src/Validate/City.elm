module Validate.City exposing (errors)

import Data.City exposing (City)
import Validate.Validate exposing (fold, isBlank, isSelected)



errors : City -> List String
errors model =
    -- Order matters!
    [ isBlank model.name "City cannot be blank."
    , isBlank model.state "State cannot be blank."
    , isBlank model.zip "Zip Code cannot be blank."
    , isSelected model.county "Please select a County."
    ]
        |> fold


