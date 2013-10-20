# -- coffee --

_ = require 'underscore'
buyan = require 'bunyan'

exports.name = 'log'

exports.attach = (options) ->
  config = @config.get 'bunyan'
  if config.stream?
    config.stream = eval config.stream
  else if config.streams?
    _.map config.streams, (item) ->
      if item.stream?
        item.stream = eval item.stream

  @log = new buyan.createLogger config
  @log.info "Log attached"

exports.detach = ->

exports.init = (done) ->
  done()
