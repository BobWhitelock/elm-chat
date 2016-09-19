module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Events exposing (onClick, onInput)
import Json.Encode as Encode
import Json.Decode as Decode exposing (..)
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
    , messages : List Message
    }


type User
    = Anonymous
    | Named String


type alias Message =
    { content : String
    , user : String
    }


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
            ( { model | messageInput = newInput }, Cmd.none )

        NameInput newInput ->
            ( { model | nameInput = newInput }, Cmd.none )

        Send ->
            ( { model | messageInput = "" }, WebSocket.send "ws://echo.websocket.org" (newMessageJson model) )

        NewMessage json ->
            ( { model | messages = (decodeMessage json) :: model.messages }, Cmd.none )

        SetName ->
            ( { model | user = Named model.nameInput }, Cmd.none )


newMessageJson : Model -> String
newMessageJson model =
    let
        message =
            Message model.messageInput (nameOf model.user)
    in
        encodeMessage message


encodeMessage : Message -> String
encodeMessage message =
    Encode.encode 0 (messageEncodeFormat message)


messageEncodeFormat : Message -> Encode.Value
messageEncodeFormat message =
    Encode.object
        [ ( "content", Encode.string message.content )
        , ( "user", Encode.string message.user )
        ]


decodeMessage : String -> Message
decodeMessage json =
    let
        result =
            attemptDecodeMessage json
    in
        case result of
            Ok message ->
                message

            Err error ->
                -- TODO: Handle this better - with message type for errors?
                Message error "ERROR"


attemptDecodeMessage : String -> Result String Message
attemptDecodeMessage json =
    let
        decoder =
            Decode.object2 Message
                ("content" := Decode.string)
                ("user" := Decode.string)
    in
        Decode.decodeString decoder json


addMessage : String -> Model -> List Message
addMessage content model =
    Message content (nameOf model.user) :: model.messages



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
    span [] [ text ("You are currently " ++ (nameOf model.user)) ]


nameOf : User -> String
nameOf user =
    case user of
        Named name ->
            name

        Anonymous ->
            "anonymous"


nameInput : Model -> Html Msg
nameInput model =
    div []
        [ input [ onInput NameInput ] []
        , button [ onClick SetName ] [ text "Set Name" ]
        ]


messages : Model -> Html Msg
messages model =
    div []
        [ div [] (List.reverse (List.map viewMessage model.messages))
        , input [ onInput MessageInput ] []
        , button [ onClick Send ] [ text "Send" ]
        ]


viewMessage : Message -> Html msg
viewMessage message =
    div [] [ text (message.user ++ ": " ++ message.content) ]
