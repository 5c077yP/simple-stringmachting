# -- coffee --

exports.name = 'outputHandler'

exports.attach = (options) ->
  @outputHandler = new OutputHandler @, @config.get 'outputHandler'
  @log.info "outputHandler attached"

exports.detach = ->
  @outputHandler.stop()

exports.init = (done) ->
  @outputHandler.init done

class OutputHandler
  constructor: (@app, config) ->
    @app.matcher.on 'match', (matches) ->
      console.log JSON.stringify matches

  init: (done) ->
    done()

  stop: ->
