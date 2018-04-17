module Validate.FundingSource exposing (Field, errors)

import Data.FundingSource exposing (FundingSource)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = Name



errors : FundingSource -> List ( Field, String )
errors fundingSource =
    validate modelValidator fundingSource


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) FundingSource
modelValidator =
    Validate.all
        [ ifBlank .name ( Name, message )
        ]


