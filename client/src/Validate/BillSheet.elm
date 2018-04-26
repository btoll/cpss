module Validate.BillSheet exposing (Field(..), errors)

import Data.BillSheet exposing (BillSheet)
import Validate exposing (Validator, ifBlank, ifNotInt, validate)



type Field
    = Consumer
    | County
    | RecipientID
    | ServerError
    | ServiceCode
    | ServiceDate



errors : BillSheet -> List ( Field, String )
errors billsheet =
    validate modelValidator billsheet
--errors : Model -> List ( Field, String )
--errors model =
--    validate modelValidator model


message : String
message =
    "Cannot be blank."



type alias Model =
        { serviceDate : String, consumer : String }

modelValidator : Validator ( Field, String ) BillSheet
--modelValidator : Validator ( Field, String ) Model
modelValidator =
    Validate.all
--        [ ifBlank .recipientID ( RecipientID, message )
--        , ifBlank .serviceDate ( ServiceDate, message )
--        ]
        [ ifBlank .serviceDate ( ServiceDate, message )
--        , ifNotInt .consumer ( Consumer, "Select a consumer" )
        ]


