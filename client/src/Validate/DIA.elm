module Validate.DIA exposing (Field, errors)

import Data.DIA exposing (DIA)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = Name



errors : DIA -> List ( Field, String )
errors dia =
    validate modelValidator dia


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) DIA
modelValidator =
    Validate.all
        [ ifBlank .name ( Name, message )
        ]


