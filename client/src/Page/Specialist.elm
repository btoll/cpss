module Page.Specialist exposing (Model, Msg, init, update, view)

import Data.Pager exposing (Pager)
import Data.PayHistory as DataPayHistory exposing (PayHistory)
import Data.Search exposing (Query, fmtFuzzyMatch)
import Data.User as User exposing (User, UserWithPager, new)
import Dict exposing (Dict)
import Html exposing (Html, Attribute, button, div, form, h1, h3, input, label, li, section, text, ul)
import Html.Attributes exposing (autofocus, action, autofocus, checked, class, for, hidden, id, step, style, type_, value)
import Html.Events exposing (onCheck, onClick, onInput, onSubmit)
import Http
import Request.PayHistory
import Request.Session
import Request.Specialist
import Search.Specialist
import Table exposing (defaultCustomizations)
import Task exposing (Task)
import Validate.Specialist
import Views.Errors as Errors
import Views.Form as Form
import Views.Modal as Modal
import Views.Page exposing (ViewAction(..), pageTitle)
import Views.Pager



-- MODEL


type alias Model =
    { errors : List String
    , tableState : Table.State
    , action : ViewAction
    , editing : Maybe User
    , disabled : Bool
    , newPassword : String
    , confirmPassword : String
    , showModal : ( Bool, Maybe Modal.Modal )
    , specialists : List User
    , payHistory : List PayHistory
    , query : Maybe Query
    , pager : Pager
    }



init : String -> ( Model, Cmd Msg )
init url =
    { errors = []
    , tableState = Table.initialSort "ID"
    , action = None
    , editing = Nothing
    , disabled = True
    , newPassword = ""
    , confirmPassword = ""
    , showModal = ( True, Modal.Spinner |> Just )
    , specialists = []
    , payHistory = []
    , query = Search.Specialist.defaultQuery |> Just
    , pager = Data.Pager.new
    } ! [ 0
            |> Request.Specialist.page url
                ( String.dropRight 5 << Dict.foldl fmtFuzzyMatch "" <| Search.Specialist.defaultQuery )
            |> Http.send FetchedSpecialists
        ]



-- UPDATE


type Msg
    = Add
    | Cancel
    | ChangePassword User
    | ClearSearch
    | Delete User
    | Deleted ( Result Http.Error User )
    | Edit User
    | FetchedSpecialists ( Result Http.Error UserWithPager )
    | Hashed ( Result Http.Error User )
    | ModalMsg Modal.Msg
    | NewPage ( Maybe Int )
    | Post
    | Posted ( Result Http.Error User )
    | Put ViewAction
    | Putted ( Result Http.Error User )
    | Search
    | SetCheckboxValue ( Bool -> User ) Bool
    | SetFormValue ( String -> User ) String
    | SetPasswordValue ( String -> Model ) String
    | SetTableState Table.State
    | ShowPayHistory User
    | ShowPayHistoryList ( Result Http.Error ( List PayHistory ) )


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update url msg model =
    case msg of
        Add ->
            { model |
                action = Adding
                , disabled = True
                , editing = Nothing
                , errors = []
            } ! []

        Cancel ->
            { model |
                action = None
                , newPassword = ""
                , confirmPassword = ""
                , editing = Nothing
                , errors = []
            } ! []

        ChangePassword specialist ->
            { model |
                action = ChangingPassword specialist
                , editing = specialist |> Just
            } ! []

        ClearSearch ->
            { model |
                query = Nothing
            } ! [ 0
                    |> Request.Specialist.page url ""
                    |> Http.send FetchedSpecialists
                ]

        Delete specialist ->
            { model |
                editing = specialist |> Just
                , showModal = ( True , Nothing |> Modal.Delete Modal.Standard |> Just )
                , errors = []
            } ! []

        Deleted ( Ok specialist ) ->
            { model |
                specialists = model.specialists |> List.filter ( \m -> specialist.id /= m.id )
            } ! []

        Deleted ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                action = None
                , errors = (::) e model.errors
            } ! []

        Edit specialist ->
            { model |
                action = Editing
                , disabled = True
                , editing = specialist |> Just
                , errors = []
            } ! []

        FetchedSpecialists ( Ok specialists ) ->
            { model |
                specialists = specialists.users
                , pager = specialists.pager
                , showModal = ( False, Nothing )
                , tableState = Table.initialSort "ID"
            } ! []

        FetchedSpecialists ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                specialists = []
                , errors = (::) e model.errors
                , showModal = ( False, Nothing )
                , tableState = Table.initialSort "ID"
            } ! []

        Hashed ( Ok specialist ) ->
            let
                newSpecialist =
                    case model.editing of
                        Nothing ->
                            specialist

                        Just current ->
                            { current | password = specialist.password }

                subCmd =
                    Request.Specialist.put url newSpecialist
                        |> Http.toTask
                        |> Task.attempt Putted
            in
                { model |
                    action = None
                } ! [ subCmd ]

        Hashed ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                action = None
                , errors = (::) e model.errors
            } ! []

        ModalMsg subMsg ->
            let
                ( showModal, whichModal, query, cmd ) =
                    case subMsg |> Modal.update model.query of
                        {- Delete Modal -}
                        ( False, Nothing ) ->
                            ( False, Nothing, Nothing, Cmd.none )

                        ( True, Nothing ) ->
                            ( False, Nothing, Nothing
                            , Maybe.withDefault new model.editing
                                |> Request.Specialist.delete url
                                |> Http.toTask
                                |> Task.attempt Deleted
                            )

                        {- Search Modal -}
                        ( False, Just query ) ->
                            let
                                q =
                                    String.dropRight 5   -- Remove the trailing " AND ".
                                        << Dict.foldl fmtFuzzyMatch ""
                                        <| query
                            in
                            ( True
                            , Modal.Spinner |> Just
                            , query |> Just     -- We need to save the search query for paging!
                            , Request.Specialist.page url q 0
                                |> Http.send FetchedSpecialists
                            )

                        ( True, Just query ) ->
                            ( True
                            , Nothing
                                |> Modal.Search Data.Search.User Nothing model.query
                                |> Just
                            , query |> Just
                            , Cmd.none
                            )
            in
            { model |
                query = query
                , showModal = ( showModal, whichModal )
            } ! [ cmd ]

        NewPage page ->
            let
                fn : String -> String -> String -> String
                fn k v acc =
                    k ++ "=" ++ v ++ " AND "
                        |> (++) acc

                s =
                    model.query
                        |> Maybe.withDefault Dict.empty
                        |> Dict.foldl fn ""
                        |> String.dropRight 5   -- Remove the trailing " AND ".
            in
            model !
            [ page
                |> Maybe.withDefault -1
                |> Request.Specialist.page url s
                |> Http.send FetchedSpecialists
            ]

        Post ->
            let
                errors =
                    case model.editing of
                        Nothing ->
                            []

                        Just specialist ->
                            Validate.Specialist.errors specialist

                subCmd = if errors |> List.isEmpty then
                    case model.editing of
                        Nothing ->
                            Cmd.none

                        Just specialist ->
                            Request.Specialist.post url specialist
                                |> Http.toTask
                                |> Task.attempt Posted
                    else
                        Cmd.none
            in
                { model |
                    disabled = True
                    , errors = errors
                } ! [ subCmd ]

        Posted ( Ok specialist ) ->
            { model |
                action = None
                , editing = Nothing
                , errors = []
                , specialists =
                    model.specialists
                        |> (::) specialist
                        |> List.sortBy .lastname
            } ! []

        Posted ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                errors = (::) e model.errors
            } ! []

        Put action ->
            case action of
                Editing ->
                    let
                        errors =
                            case model.editing of
                                Nothing ->
                                    []

                                Just specialist ->
                                    Validate.Specialist.errors specialist

                        subCmd = if errors |> List.isEmpty then
                            case model.editing of
                                Nothing ->
                                    Cmd.none

                                Just specialist ->
                                    Request.Specialist.put url specialist
                                        |> Http.toTask
                                        |> Task.attempt Putted
                            else
                                Cmd.none
                    in
                        { model |
                            disabled = True
                            , errors = errors
                        } ! [ subCmd ]

                ChangingPassword specialist ->
                    let
                        subCmd =
                            { specialist | password = model.newPassword }
                                |> Request.Session.hash url
                                    |> Http.toTask
                                    |> Task.attempt Hashed
                    in
                        { model |
                            disabled = True
                            , newPassword = ""
                            , confirmPassword = ""
                        } ! [ subCmd ]

                _ ->
                    model ! []

        Putted ( Ok specialist ) ->
            let
                specialists =
                    case model.editing of
                        Nothing ->
                            model.specialists

                        Just newSpecialist ->
                            model.specialists
                                -- Keep sort order.
                                |> List.map ( \m ->
                                        if specialist.id /= m.id
                                        then m
                                        else { newSpecialist |
                                            id = specialist.id
                                            , password = specialist.password
                                        }
                                    )
            in
                { model |
                    action = None
                    , errors = []
                    , specialists = specialists
                    , editing = Nothing
                } ! []

        Putted ( Err err ) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                errors = (::) e model.errors
            } ! []

        Search ->
            { model |
                showModal = ( True, Nothing |> Modal.Search Data.Search.User Nothing model.query |> Just )
                , errors = []
            } ! []

        SetCheckboxValue setBoolValue b ->
            { model |
                editing = setBoolValue b |> Just
                , disabled = False
            } ! []

        SetFormValue setFormValue s ->
            { model |
                editing = s |> setFormValue |> Just
                , disabled = False
            } ! []

        SetPasswordValue setPasswordValue s ->
            let
                m =
                    s |> setPasswordValue

                passwordsMatch : Bool
                passwordsMatch =
                    if (
                        -- Only enable button if both passwords aren't an empty string AND they match!
                        (
                            ( (==) "" m.confirmPassword ) &&
                            ( (==) "" m.newPassword )
                        ) ||
                            (/=) m.newPassword m.confirmPassword
                        )
                    then True
                    else False
            in
            { m | disabled = passwordsMatch } ! []

        SetTableState newState ->
            { model |
                tableState = newState
            } ! []

        ShowPayHistory specialist ->
            let
                subCmd =
                    Request.PayHistory.list url specialist.id
                        |> Http.toTask
                        |> Task.attempt ShowPayHistoryList
            in
            { model |
                action = Views.Page.PayHistory specialist
            } ! [ subCmd ]

        ShowPayHistoryList ( Ok payhistory ) ->
            { model |
                payHistory = payhistory
            } ! []

        ShowPayHistoryList ( Err err) ->
            let
                e =
                    case err of
                        Http.BadStatus e ->
                            e.body

                        _ ->
                            "nop"
            in
            { model |
                editing = Nothing
                , errors = (::) e model.errors
            } ! []


-- VIEW


view : Model -> Html Msg
view model =
    section []
        ( (++)
            [ h1 [] [ "Specialists" |> pageTitle model.action |> text ]
            , Errors.view model.errors
            ]
            ( drawView model )
        )


drawView : Model -> List ( Html Msg )
drawView (
    { action
    , disabled
    , editing
    , tableState
    , specialists
    , payHistory
    , query
    } as model ) =
    let
        editable : User
        editable = case editing of
            Nothing ->
                new

            Just specialist ->
                specialist

        showList =
            case specialists |> List.length of
                0 ->
                    div [] []
                _ ->
                    Table.view config tableState specialists

        showPager =
            model.pager |> Views.Pager.view NewPage

        hideClearTextButton =
            case query of
                Nothing ->
                    True

                Just _ ->
                    False
    in
    case action of
        None ->
            [ div [ "buttons" |> class ]
                [ button [ onClick Add ] [ text "Add Specialist" ]
                , button [ Search |> onClick ] [ text "Search" ]
                , button [ hideClearTextButton |> hidden, ClearSearch |> onClick ] [ text "Clear Search" ]
                ]
            , showPager
            , showList
            , showPager
            , model.showModal
                |> Modal.view Nothing query
                |> Html.map ModalMsg
            ]

        Adding ->
            [ form [ onSubmit Post ]
                ( (++)
                    ( editable |> formRows action )
                    [ Form.submit disabled Cancel ]
                )
            ]

        Editing ->
            [ form [ onSubmit ( Put Editing ) ]
                ( (++)
                    ( editable |> formRows action )
                    [ Form.submit disabled Cancel ]
                )
            ]

        ChangingPassword specialist ->
            [ form [ onSubmit ( Put ( ChangingPassword specialist ) ) ]
                [ Form.password "New Password"
                    [ value model.newPassword
                    , True |> autofocus
                    , onInput ( SetPasswordValue (\v -> { model | newPassword = v } ) )
                    ]
                    []
                , Form.password "Confirm Password"
                    [ value model.confirmPassword
                    , onInput ( SetPasswordValue (\v -> { model | confirmPassword = v } ) )
                    ]
                    []
                , Form.submit disabled Cancel
                ]
            ]

        PayHistory specialist ->
            let
                fmtPayrate payrate =
                    payrate
                        |> toString
                        |> (++) " $"
            in
            [ div [ "unitsBlock" |> id ]
                [ h3 [] [
                    ( specialist.firstname ++ " " ++ specialist.lastname ++ " (" ++ specialist.username ++ ")" )
                    |> text
                ]
                , ul []
                    ( payHistory
                        |> List.map (
                            \ph -> li [] [
                                ph.payrate
                                    |> fmtPayrate
                                    |> (++) ph.changeDate
                                    |> text
                            ]
                        )
                    )
                ]
                , Form.submit True Cancel
            ]

        _ ->
            [ div [] []
            ]


formRows : ViewAction -> User -> List ( Html Msg )
formRows action editable =
    [ Form.text "Username"
        [ value editable.username
        , onInput ( SetFormValue ( \v -> { editable | username = v } ) )
        , autofocus True
        ]
        []
    , Form.password "Password"
        [ value editable.password
        , onInput ( SetFormValue ( \v -> { editable | password = v } ) )
        , ( if (==) action Adding then False else True ) |> Html.Attributes.disabled
        ]
        []
    , Form.text "First Name"
        [ value editable.firstname
        , onInput ( SetFormValue (\v -> { editable | firstname = v } ) )
        ]
        []
    , Form.text "Last Name"
        [ value editable.lastname
        , onInput ( SetFormValue (\v -> { editable | lastname = v } ) )
        ]
        []
    , Form.checkbox "Active"
        [ checked editable.active
        , onCheck ( SetCheckboxValue ( \v -> { editable | active = v } ) )
        ]
        []
    , Form.text "Email"
        [ value editable.email
        , onInput ( SetFormValue (\v -> { editable | email = v } ) )
        ]
        []
    , Form.float "Pay Rate"
        [ editable.payrate |> toString |> value
        , onInput ( SetFormValue (\v -> { editable | payrate = Form.toFloat v } ) )
        , step "0.01"
        ]
        []
    , Form.select "Auth Level"
        [ id "authLevelSelection"
        , onInput ( SetFormValue (\v -> { editable | authLevel = Form.toInt v } ) )
        ] (
            [ ( "-1", "-- Select an auth level --" ), ( "1", "Admin" ), ( "2", "User" ) ]
                |> List.map ( editable.authLevel |> toString |> Form.option )
        )
    ]



-- TABLE CONFIGURATION


config : Table.Config User Msg
config =
    Table.customConfig
    { toId = .id >> toString
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Full Name" ( \m ->        -- "Cricket, Rickety"
            (++)
                ( .lastname m )
                ( (++)
                    ( ", ")
                    ( .firstname m )
                )
        )
        , Table.stringColumn "First Name" .firstname
        , Table.stringColumn "Last Name" .lastname
        , customColumn viewCheckbox "Active"
        , Table.stringColumn "Username" .username
        , Table.stringColumn "Email" .email
        , Table.floatColumn "Pay Rate" .payrate
        , Table.stringColumn "Auth Level" ( .authLevel >> toString >> ( \s -> if s |> (==) "1" then "Admin" else "User" ) )
        , customColumn ( viewButton Edit "Edit" ) ""
        , customColumn ( viewButton Delete "Delete" ) ""
        , customColumn ( viewButton ChangePassword "Change Password" ) ""
        , customColumn ( viewButton ShowPayHistory "Pay History" ) ""
        ]
    , customizations = defaultCustomizations
    }


customColumn : ( User -> Table.HtmlDetails Msg ) -> String -> Table.Column User Msg
customColumn viewElement header =
    Table.veryCustomColumn
        { name = header
        , viewData = viewElement
        , sorter = Table.unsortable
        }


viewButton : ( User -> msg ) -> String -> User -> Table.HtmlDetails msg
viewButton msg name specialist =
    Table.HtmlDetails []
        [ button [ onClick <| msg <| specialist ] [ text name ]
        ]


viewCheckbox : User -> Table.HtmlDetails Msg
viewCheckbox { active } =
  Table.HtmlDetails []
    [ input [ checked active, Html.Attributes.disabled True, type_ "checkbox" ] []
    ]


