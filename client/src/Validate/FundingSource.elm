module Validate.FundingSource exposing (errors)

import Data.FundingSource exposing (FundingSource)
import Validate.Validate exposing (fold, isBlank)



errors : FundingSource -> List String
errors model =
    [ isBlank model.name "FundingSource cannot be blank."
    ]
        |> fold


