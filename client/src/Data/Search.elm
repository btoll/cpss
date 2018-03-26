module Data.Search exposing (Search(..), Query, ViewLists, fmtEquality, fmtFuzzyMatch)

import Data.BillSheet exposing (BillSheet, BillSheetWithPager)
import Data.City exposing (City, CityWithPager)
import Data.Consumer exposing (Consumer, ConsumerWithPager)
import Data.County exposing (County)
import Data.ServiceCode exposing (ServiceCode)
import Data.Status exposing (Status)
import Data.TimeEntry exposing (TimeEntry, TimeEntryWithPager)
import Data.User exposing (User, UserWithPager)
import Dict exposing (Dict)



--type alias Query = List ( String, String )
type alias Query = Dict String String


type alias ViewLists =
    { billsheets : List BillSheet
    , consumers : List Consumer
    , counties : List County
    , specialists : List User
    , status : List Status
    }


fmtEquality : String -> String -> String -> String
fmtEquality k v acc =
    k ++ "=" ++ v ++ " AND "
        |> (++) acc


fmtFuzzyMatch : String -> String -> String -> String
fmtFuzzyMatch k v acc =
    k ++ " LIKE '%" ++ v ++ "%'" ++ " AND "
        |> (++) acc


type Search
    = BillSheet
   -- | BillSheetWithPager
    | City
  --  | CityWithPager
    | Consumer
 --   | ConsumerWithPager
    | County
    | ServiceCode
    | Status
    | TimeEntry
--    | TimeEntryWithPager
    | User
--    | UserWithPager


