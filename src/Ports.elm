port module Ports exposing (..)

import Json.Encode exposing (Value)


port sendMessage : Value -> Cmd msg


port receiveMessage : (Value -> msg) -> Sub msg
