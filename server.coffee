express = require 'express'
routes = require './routes'
http = require 'http'
path = require 'path'
Q = require 'q'
$ = require 'cheerio'

utils = require './lib/utils'
aggregator = require './lib/aggregator'
metadata = require './package.json'

app = express()

# Middleware
app.set 'port', process.env.PORT or 3000
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade'
app.set 'title', metadata.name
app.set 'description', metadata.description
app.set 'author', metadata.author
app.set 'version', metadata.version

app.use express.compress()
app.use express.logger 'dev'
app.use express.favicon()

# Routes
app.get '/', routes.index

start = new Date()

Q
.all(aggregator.aggregate())
.then (rss) ->
  end = new Date()
  console.log "Finished aggregating feeds in #{end - start}ms"
  # Flatten
  rss = [].concat rss...
  rss[i].description = $(item.description).text() for item, i in rss
  app.set 'rss', utils.shuffle(rss)
.then ->
  http.createServer(app).listen app.get('port'), ->
    console.log "Express server listening on port #{app.get('port')}"
.fail (err) ->
  console.error err
