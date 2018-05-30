module Validate.TimeEntry exposing (errors)

import Data.BillSheet exposing (BillSheet)
import Validate.Validate exposing (fold, isBlank, isSelected, isZero)



errors : BillSheet -> List String
errors model =
    [ isSelected model.consumer "Please select a Consumer."
    , isBlank model.serviceDate "Service Date cannot be blank."
    , isSelected model.serviceCode "Please select a Service Code."
    , isZero model.hours "Hours cannot be zero."
    , isBlank model.description "Description cannot be blank."
    , isSelected model.county "Please select a County."
    , isBlank model.billedCode "Billed Code cannot be blank."
    ]
        |> fold


