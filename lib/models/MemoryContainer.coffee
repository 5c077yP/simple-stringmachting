# -- coffee --

AbstractContainer = require './AbstractContainer'

class MemoryContainer extends AbstractContainer
  constructor: (@app) ->
    @container = {}

  stop: ->

  _load: (key, cb) ->
    @container[key] = [] unless @container[key]?
    process.nextTick () =>
      cb @container[key]

  _append: (key, value, data, cb) ->
    data.push value
    @container[key] = data
    process.nextTick () =>
      cb data

module.exports = MemoryContainer
