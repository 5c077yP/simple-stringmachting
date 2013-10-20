# -- coffee --

exports.name = 'container'

exports.attach = (options) ->
  containerType = @config.get 'container'
  container = require "../models/#{containerType}"
  @container = new container @, @config.get containerType
  @log.info "Container::#{containerType} attached"

exports.detach = ->
  @container.stop()

exports.init = (done) ->
  done()
