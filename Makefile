
.PHONY: start
start: app view

.PHONY: app
app:
	elm make src/Main.elm --output=build/app.js --warn

.PHONY: view
view:
	xdg-open http://localhost:8000
	python -m SimpleHTTPServer 8000

.PHONY: styles
styles:
	node_modules/node-sass/bin/node-sass --watch src/styles/main.scss --include-path node_modules/foundation-sites/scss/ > build/styles.css
.PHONY: server
server:
	node faye_server/server.js
