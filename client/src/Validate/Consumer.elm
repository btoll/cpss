module Validate.Consumer exposing (Field, errors)

import Data.Consumer exposing (Consumer)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = FirstName
    | LastName
    | DischargeDate



errors : Consumer -> List ( Field, String )
errors consumer =
    validate modelValidator consumer


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) Consumer
modelValidator =
    Validate.all
        [ ifBlank .firstname ( FirstName, message )
        , ifBlank .lastname ( LastName, message )
        , ifBlank .dischargeDate ( DischargeDate, message )
        ]


