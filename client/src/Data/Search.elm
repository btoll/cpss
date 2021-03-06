module Data.Search exposing (SearchType(..), Query, ViewLists, fmtDates, fmtEquality, fmtFuzzyMatch)


import Data.BillSheet exposing (BillSheet, BillSheetWithPager)
import Data.Consumer exposing (Consumer, ConsumerWithPager)
import Data.County exposing (County, CountyWithPager)
import Data.ServiceCode exposing (ServiceCode)
import Data.Status exposing (Status)
import Data.User exposing (User, UserWithPager)
import Dict exposing (Dict)



type alias Query
    = Dict String String


type alias ViewLists =
    { billsheets : Maybe ( List BillSheet )
    , consumers : Maybe ( List Consumer )
    , counties : Maybe ( List County )
    , serviceCodes : Maybe ( List ServiceCode )
    , specialists : Maybe ( List User )
    , status : Maybe ( List Status )
    }



fmtDates : String -> String -> String
fmtDates v acc =
    v ++ " AND "
        |> (++) acc


fmtEquality : String -> String -> String -> String
fmtEquality k v acc =
    k ++ "=" ++ v ++ " AND "
        |> (++) acc


fmtFuzzyMatch : String -> String -> String -> String
fmtFuzzyMatch k v acc =
    k ++ " LIKE '%" ++ v ++ "%'" ++ " AND "
        |> (++) acc


type SearchType
    = BillSheet
   -- | BillSheetWithPager
    | Consumer
 --   | ConsumerWithPager
    | County
--    | CountyWithPager
    | ServiceCode
    | Status
    | TimeEntry
    | User
--    | UserWithPager


