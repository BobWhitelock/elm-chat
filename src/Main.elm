
import Html exposing (..)
import Html.App as Html
import Html.Events exposing (onClick, onInput)
import WebSocket



main : Program Never
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { user : User
  , nameInput : String
  , messageInput : String
  , messages : List String
  }


type User
  = Anonymous
  | Named String


initialModel : Model
initialModel =
  Model Anonymous "" "" []


init : ( Model, Cmd Msg )
init =
  ( initialModel, Cmd.none )



-- UPDATE


type Msg
  = MessageInput String
  | NameInput String
  | Send
  | NewMessage String
  | SetName


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    MessageInput newInput ->
      ({model | messageInput = newInput}, Cmd.none)

    NameInput newInput ->
      ({model | nameInput = newInput}, Cmd.none)

    Send ->
      ({model | messageInput = ""}, WebSocket.send "ws://echo.websocket.org" model.messageInput)

    NewMessage str ->
      ({model | messages = (str :: model.messages)}, Cmd.none)

    SetName ->
      ({model | user = Named model.nameInput}, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://echo.websocket.org" NewMessage



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ userInfo model
    , nameInput model
    , messages model
    ]


userInfo : Model -> Html Msg
userInfo model =
  span [] [text ("You are currently " ++ (nameOf model.user))]

nameOf : User -> String
nameOf user =
  case user of
    Named  name ->
      name
    Anonymous ->
      "anonymous"

nameInput : Model -> Html Msg
nameInput model =
  div []
    [ input [onInput NameInput] []
    , button [onClick SetName] [text "Set Name"]
    ]


messages : Model -> Html Msg
messages model =
  div []
    [ div [] (List.reverse (List.map viewMessage model.messages))
    , input [onInput MessageInput] []
    , button [onClick Send] [text "Send"]
    ]

viewMessage : String -> Html msg
viewMessage msg =
  div [] [ text msg ]
