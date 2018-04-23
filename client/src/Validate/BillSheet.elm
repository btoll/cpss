module Validate.BillSheet exposing (Field(..), errors)

import Data.BillSheet exposing (BillSheet)
import Validate exposing (Validator, ifBlank, validate)



type Field
    = RecipientID
    | ServiceDate
    | ServerError



--    { id : String
--    , recipientID : String
--    , serviceDate : String
--    , billedAmount : Float
--    , consumer : String
--    , status : String
--    , confirmation : String
--    , service : String
--    , county : String
--    , specialist : String
--    , recordNumber : String
--    , selected : Bool
--    }
errors : BillSheet -> List ( Field, String )
errors billsheet =
    validate modelValidator billsheet


message : String
message =
    "Cannot be blank."


modelValidator : Validator ( Field, String ) BillSheet
modelValidator =
    Validate.all
--        [ ifBlank .recipientID ( RecipientID, message )
--        , ifBlank .serviceDate ( ServiceDate, message )
--        ]
        [ ifBlank .serviceDate ( ServiceDate, message )
        ]


