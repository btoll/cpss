module Validate.Status exposing (Field(..), errors)

import Data.Status exposing (Status)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = Name
    | ServerError



errors : Status -> List ( Field, String )
errors status =
    validate modelValidator status


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) Status
modelValidator =
    Validate.all
        [ ifBlank .name ( Name, message )
        ]


