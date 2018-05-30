module Validate.Validate exposing (
    fold
    , isBlank
    , isSelected
    , isZero
    )


type alias Error = String



fold : List Error -> List Error
fold =
    List.foldr
        ( \v acc -> if (==) v "" then acc else (::) v acc )
        []


isBlank : String -> Error -> Error
isBlank s error =
    if ( == ) s ""
    then error
    else ""


isSelected : Int -> Error -> Error
isSelected n error =
    if ( == ) n -1
    then error
    else ""


isZero : Float -> Error -> Error
isZero n error =
    if ( == ) n 0
    then error
    else ""


