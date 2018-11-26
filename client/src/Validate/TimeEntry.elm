module Validate.TimeEntry exposing (errors)

import Data.BillSheet exposing (BillSheet)
import Validate.Validate exposing (fold, isBlank, isFloat, isSelected, isZero)



errors : BillSheet -> List String
errors model =
    [ isSelected model.consumer "Please select a Consumer."
    , isBlank model.serviceDate "Service Date cannot be blank."
    , isSelected model.serviceCode "Please select a Service Code."
    , isFloat model.units "Hours cannot contain alphabetical characters."
    , isBlank model.description "Description cannot be blank."
    ]
        |> fold


