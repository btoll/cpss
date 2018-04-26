module Validate.Specialist exposing (Field(..), errors)

import Data.User exposing (User)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = None
    | Email
    | Password
    | ServerError
    | Username



errors : User -> List ( Field, String )
errors specialist =
    validate modelValidator specialist


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) User
modelValidator =
    Validate.all
        [ ifBlank .username ( Username, message )
        , ifBlank .password ( Password, message )
        , ifBlank .email ( Email, message )
        ]


