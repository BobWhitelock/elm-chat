
.PHONY: start
start: app view

.PHONY: app
app:
	elm make src/Main.elm --output=build/app.js --warn

.PHONY: view
view:
	xdg-open http://localhost:8000
	cd build && python -m SimpleHTTPServer 8000

.PHONY: server
server:
	node faye_server/server.js
