# -- coffee --

_ = require 'underscore'
async = require 'async'
EventEmitter2 = require('eventemitter2').EventEmitter2

exports.name = 'matcher'

exports.attach = (options) ->
  return done new Error 'EventReader is missing' unless @eventReader?
  @matcher = new Matcher @, @config.get 'matcher'
  @log.info "Matcher attached"

exports.detach = ->
  @matcher.stop()

exports.init = (done) ->
  @matcher.init done


class Matcher extends EventEmitter2
  constructor: (@app, config) ->
    @trackedIds = config.tracked_ids
    @hexLens = config.hex_lens
    @app.eventReader.on 'event', (event) =>
      t = new Date()
      @_onEvent event, (matches) =>
        @app.statsd.timing 'matcher.onEvent', t
        if matches
          @app.statsd.increment 'matcher.foundMatches'
          @emit 'match', matches
    @app.eventReader.on 'end', =>
      @emit 'end'

  init: (done) =>
    done()

  stop: ->

  _ignoreEvents: (event) ->
    if event.campaign? and 3 > parseInt event.campaign, 10
        console.error "ignoring event -> #{event}"
        @app.statsd.increment 'matcher.ignoredEvents'
        return true
    return false

  _getTrackedFields: (event) ->
    fields = {}
    for tracked in @trackedIds
      continue unless event[tracked]?
      continue unless event[tracked].length in @hexLens
      fields[tracked] = event[tracked]
    return fields

  _onEvent: (event, done) ->
    @app.statsd.increment 'matcher.onEvent.calls'
    try
      # filter test events
      return done null if @_ignoreEvents event

      # get the static fields to compare events later on
      aid = event.actionId
      etype = parseInt event.TMEvent, 10
      etime = parseInt event.TMTimeEvent, 10
      data = [aid, etype, etime]

      # get all tracked fields
      tracked = @_getTrackedFields event

      # try to match
      matchType = if etype == 14 then 13 else 14
      async.map _.keys(tracked), (idName, cb) =>
        stored = data.concat [idName]
        idSet = @app.container.check tracked[idName], stored
        return cb null, null unless idSet.length
        # find whether this was an event match
        matches = _.filter idSet, (d) => d[1] == matchType
        return cb null, null unless matches.length
        return cb null, [stored, tracked[idName], matches]
      , (err, results) =>
        throw err if err?
        matches = _.compact results
        return done null unless matches.length
        done matches
    catch e
      @app.log.error e
      @app.statsd.increment 'matcher.onEvent.errors'
    return done null
