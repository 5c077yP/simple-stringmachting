# -- coffee --

statsd = require 'statsd-client'

exports.name = 'statsd'

exports.attach = (options) ->
  @statsd = new statsd @config.get 'statsd'
  @log.info "statsd attached"

exports.detach = ->
  @statsd.close()
  @log.warn 'Statsd client stopped'

exports.init = (done) ->
  done()
