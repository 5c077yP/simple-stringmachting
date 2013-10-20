# -- coffee --

statsd = require 'statsd-client'

exports.name = 'statsd'

exports.attach = (options) ->
  @statsd = new statsd @config.get 'statsd'
  @log.info "statsd attached"

exports.detach = ->
  @statsd.close()

exports.init = (done) ->
  done()
