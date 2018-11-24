module Util.Currency exposing (format)
import Native.Currency



format : Float -> String
format num =
    let
        res =
            Native.CurrencyFormat.format num
    in
        case res of
            Ok str ->
                str
            Err err ->
                let
                    _ =
                        Debug.log "CurrencyFormatError" err
                in
                toString num


