#!/usr/bin/env coffee

###
  This is a refenrece implementation of a simple string matching algorithm
  using nodejs/coffee-script. This is not about a fast implementation of
  string matching but more a proof of concept for scalable and high-available
  string matching using a scalable and high-available database
                       - Apache Cassandra -
###

broadway = require 'broadway'
app = new broadway.App()

##
# Configure my app
##
app.config.argv
  t:
    alias: 'container',
    demand: true,
    describe: 'the container class used [possible: MemoryContainer]'
  c:
    alias: 'config',
    demand: true,
    describe: '/path/to/config/json'

app.config.file
  file: app.config.get 'config'

##
# Add the plugins
##
app.use require './lib/plugins/Logging'
app.use require './lib/plugins/StatsdClient'
app.use require './lib/plugins/MemoryMeasure'
app.use require './lib/plugins/EventReader'
app.use require './lib/plugins/Container'
app.use require './lib/plugins/Matcher'
app.use require './lib/plugins/OutputHandler'

# app.matcher.on 'end', ->
  # app.remove 'memoryMeasure'
  # app.remove 'statsd'
  # app.remove 'container'

process.on 'SIGINT', ->
  app.remove 'memoryMeasure'
  app.remove 'statsd'
  app.remove 'eventReader'
  app.remove 'container'
  setTimeout (-> process.exit 1), 1000

app.init (err) ->
  throw err if err?
