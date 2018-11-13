module Validate.BillSheet exposing (errors)

import Data.BillSheet exposing (BillSheet)
import Validate.Validate exposing (fold, isBlank, isSelected, isZero)



errors : BillSheet -> List String
errors model =
    -- Order matters!
    [ isBlank model.formattedDate "Please enter a Service Date."
    , isSelected model.serviceCode "Please select a Service Code."
--    , isZero model.units "Units cannot be zero."
--    , isZero model.billedAmount "Billed Amount cannot be zero."
    , isSelected model.consumer "Please select a Consumer."
    , isSelected model.specialist "Please select a Specialist."
    ]
        |> fold


