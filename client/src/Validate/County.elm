module Validate.County exposing (Field, errors)

import Data.County exposing (County)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = Name



errors : County -> List ( Field, String )
errors county =
    validate modelValidator county


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) County
modelValidator =
    Validate.all
        [ ifBlank .name ( Name, message )
        ]


