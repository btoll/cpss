module Validate.Specialist exposing (errors)

import Data.User exposing (User)
import Validate.Validate exposing (fold, isBlank, isSelected, isZero)



errors : User -> List String
errors model =
    [ isBlank model.username "Username cannot be blank."
    , isBlank model.password "Password cannot be blank."
    , isBlank model.firstname "First Name cannot be blank."
    , isBlank model.lastname "Last Name cannot be blank."
    , isBlank model.email "Email cannot be blank."
    , isZero model.payrate "Pay Rate cannot be zero."
    , isSelected model.authLevel "Please select an Auth Level."
    ]
        |> fold


