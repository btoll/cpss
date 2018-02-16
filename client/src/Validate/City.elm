module Validate.City exposing (Field, errors)

import Data.City exposing (City)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = Name



errors : City -> List ( Field, String )
errors city =
    validate modelValidator city


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) City
modelValidator =
    Validate.all
        [ ifBlank .name ( Name, message )
        ]


