module Validate.ServiceCode exposing (Field, errors)

import Data.ServiceCode exposing (ServiceCode)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = Name



errors : ServiceCode -> List ( Field, String )
errors serviceCode =
    validate modelValidator serviceCode


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) ServiceCode
modelValidator =
    Validate.all
        [ ifBlank .name ( Name, message )
        ]


