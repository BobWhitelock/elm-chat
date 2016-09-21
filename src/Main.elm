module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as Encode
import Json.Decode as Decode exposing ((:=))
import String
import List
import Ports exposing (sendMessage, receiveMessage)


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
    | NewMessage Encode.Value
    | SetName


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MessageInput newInput ->
            ( { model | messageInput = newInput }, Cmd.none )

        NameInput newInput ->
            ( { model | nameInput = newInput }, Cmd.none )

        Send ->
            ( { model | messageInput = "" }, sendMessage (newMessageJson model) )

        NewMessage json ->
            ( { model | messages = (List.append model.messages [ decodeMessage json ]) }, Cmd.none )

        SetName ->
            ( { model | user = Named model.nameInput, nameInput = "" }, Cmd.none )


newMessageJson : Model -> Encode.Value
newMessageJson model =
    let
        message =
            Message model.messageInput (nameOf model.user)
    in
        encodeMessage message


encodeMessage : Message -> Encode.Value
encodeMessage message =
    Encode.object
        [ ( "content", Encode.string message.content )
        , ( "user", Encode.string message.user )
        ]


decodeMessage : Encode.Value -> Message
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


attemptDecodeMessage : Encode.Value -> Result String Message
attemptDecodeMessage json =
    let
        decoder =
            Decode.object2 Message
                ("content" := Decode.string)
                ("user" := Decode.string)
    in
        Decode.decodeValue decoder json



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    receiveMessage NewMessage



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
        [ input
            [ (onInput NameInput)
            , (value model.nameInput)
            ]
            []
        , button
            [ (onClick SetName)
            , (disabled (String.isEmpty model.nameInput))
            ]
            [ text "Set Name" ]
        ]


messages : Model -> Html Msg
messages model =
    div []
        [ div [] (List.map viewMessage model.messages)
        , messageInput model
        ]


viewMessage : Message -> Html Msg
viewMessage message =
    div [] [ text (message.user ++ ": " ++ message.content) ]


messageInput : Model -> Html Msg
messageInput model =
    div []
        [ input
            [ (onInput MessageInput)
            , (value model.messageInput)
            ]
            []
        , button
            [ (onClick Send)
            , (disabled (String.isEmpty model.messageInput))
            ]
            [ text "Send" ]
        ]
