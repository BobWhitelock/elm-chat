
var app = Elm.Main.fullscreen()

var client = new Faye.Client('http://localhost:8001/faye')

client.subscribe('/messages', function(message) {
  console.log('Got a message: ' + message.text);
});

setInterval(function() {
  client.publish('/messages', {
    text: 'Hello World'
  })
}, 500)
