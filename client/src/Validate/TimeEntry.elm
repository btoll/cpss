module Validate.TimeEntry exposing (Field, errors)

import Data.TimeEntry exposing (TimeEntry)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = ServiceDate



errors : TimeEntry -> List ( Field, String )
errors timeEntry =
    validate modelValidator timeEntry


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) TimeEntry
modelValidator =
    Validate.all
        [ ifBlank .serviceDate ( ServiceDate, message )
        ]


