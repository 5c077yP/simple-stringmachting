# -- coffee --

##
# Takes filenames and reads them.
# Expects new line speparated json files.
##

fs = require 'fs'

_ = require 'underscore'
EventEmitter2 = require('eventemitter2').EventEmitter2
ll = require 'lazylines'

exports.name = 'eventReader'

exports.attach = (options) ->
  @eventReader = new Subscriber @, @config.get 'eventReader'
  @log.info "EventReader attached"

exports.detach = ->
  @eventReader.stop()

exports.init = (done) ->
  @eventReader.init done


class Subscriber extends EventEmitter2
  constructor: (@app, options) ->
    @files = options.files
    @linereaders = {}

  init: (done) =>
    _.each @files, (fname) =>
      @app.log.info "Checking -> #{fname}"

      frs = fs.createReadStream fname
      @linereaders[fname] = new ll.LineReadStream frs
      @linereaders[fname].on 'line', (line) =>
        try
          @emit 'event', JSON.parse line
        catch e
          @app.log.error e

      frs.on 'error', (err) =>
        @app.log.error e
        @emit 'err', err

      frs.on 'end', =>
        @app.log.info "File completed -> #{fname}"
        delete @linereaders[fname]
        @emit 'end' if _.size(@linereaders) is 0

    done()

  stop: ->

