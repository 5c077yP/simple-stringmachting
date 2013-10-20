# -- coffee --

class AbstractContainer
  _load: (key, cb) ->
    throw new Error "Not implemented"
  _append: (key, value, data, cb) ->
    throw new Error "Not implemented"

  stop: ->
    throw new Error "Not implemented"

  check: (key, value, cb) ->
    try
      @_load key, (data) =>
        # TODO: always appending here, but value could have a structur ???
        @_append key, value, data, (data) ->
          return cb data
    catch e
      @app.log.error "AbstractContainer: #{e}"
      return cb null


module.exports = AbstractContainer
