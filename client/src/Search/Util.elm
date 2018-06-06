module Search.Util exposing (
    getBool
    , getSelection
    , getText
    , setBool
    , setSelection
    , setText
    )

import Dict exposing (Dict)
import Data.Search exposing (Query)



fromBool : Bool -> String
fromBool v =
    if v then "1" else "0"


toBool : String -> Bool
toBool v =
    if (==) "1" v then True else False


get : Dict String String -> String -> Maybe String
get q name =
    q |> Dict.get name


set : Dict String String -> String -> String -> ( String -> Bool ) -> Query
set q k v compareFn =
    if compareFn v then
        q |> Dict.remove k
    else
        q |> Dict.insert k v


getBool : Dict String String -> String -> Bool
getBool q name =
    name |> getText q |> toBool


getSelection : Dict String String -> String -> String
getSelection q name =
    name |> get q |> Maybe.withDefault "-1"


getText : Dict String String -> String -> String
getText q name =
    name |> get q |> Maybe.withDefault ""


setBool : Dict String String -> String -> Bool -> Query
setBool q k v =
    q |> Dict.insert k ( v |> fromBool )


setSelection : Dict String String -> String -> String -> Query
setSelection q k v =
    compareSelection
        |> set q k v


setText : Dict String String -> String -> String -> Query
setText q k v =
    compareText
        |> set q k v


compareSelection : String -> Bool
compareSelection v =
    (==) v "-1"


compareText : String -> Bool
compareText v =
    (==) v ""


