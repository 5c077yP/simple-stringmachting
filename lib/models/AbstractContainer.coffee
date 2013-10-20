# -- coffee --

class AbstractContainer
  _load: (key, cb) ->
    throw new Error "Not implemented"
  _append: (key, value, data, cb) ->
    throw new Error "Not implemented"

  check: (key, value, cb) ->
    @_load key, (data) =>
      # TODO: always appending here, but value could have a structur ???
      @_append key, value, data, (data) ->
          return data

module.exports = AbstractContainer
