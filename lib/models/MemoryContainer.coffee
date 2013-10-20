# -- coffee --

AbstractContainer = require './AbstractContainer'

class MemoryContainer extends AbstractContainer
  constructor: (@app) ->
    @container = {}

  _load: (key) ->
    @container[key] = [] unless @container[key]?
    return @container[key]

  _append: (key, value, data) ->
    data.push value
    @container[key] = data
    return data

module.exports = MemoryContainer
