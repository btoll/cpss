module Validate.Consumer exposing (errors)

import Data.Consumer exposing (Consumer)
import Validate.Validate exposing (fold, isBlank, isSelected, isZero)



errors : Consumer -> List String
errors model =
    [ isBlank model.firstname "First Name cannot be blank."
    , isBlank model.lastname "Last Name cannot be blank."
    , isSelected model.county "Please select a County."
--    , isSelected model.serviceCode "Please select a Service Code."
    , isSelected model.fundingSource "Please select a Funding Source."
    , isBlank model.zip "Zip Code cannot be blank."
    , isBlank model.bsu "BSU cannot be blank."
    , isBlank model.recipientID "Recipient ID cannot be blank."
    , isSelected model.dia "Please select a DIA."
--    , isZero model.units "Units cannot be zero."
    ]
        |> fold


