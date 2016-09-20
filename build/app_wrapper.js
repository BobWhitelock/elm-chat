
var FAYE_ENDPOINT = 'http://localhost:8001/faye'
var CHANNEL = '/messages'

var app = Elm.Main.fullscreen()
var fayeClient = new Faye.Client(FAYE_ENDPOINT)

// Publish every message sent from Elm using Faye server.
app.ports.sendMessage.subscribe(function(message) {
  console.log('Sending message: ' , message)

  fayeClient.publish(CHANNEL, message)
})

// Subscribe to Faye messages, and send into Elm.
fayeClient.subscribe(CHANNEL, function(message) {
  console.log('Received message: ' , message);

  app.ports.receiveMessage.send(message)
});
