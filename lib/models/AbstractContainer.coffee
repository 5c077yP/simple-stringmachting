# -- coffee --

class AbstractContainer
  _load: (key) ->
    throw new Error "Not implemented"
  _append: (key, value, data) ->
    throw new Error "Not implemented"

  check: (key, value) ->
    data = @_load key
    data = @_append key, value, data if value not in data
    return data

module.exports = AbstractContainer
