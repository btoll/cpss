port module Ports exposing (fileContentRead, fileSelected)



type alias FileData =
    { contents : String
    , filename : String
    }


port fileSelected : String -> Cmd msg


port fileContentRead : ( List FileData -> msg) -> Sub msg


