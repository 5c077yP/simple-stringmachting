# -- coffee --

_ = require 'underscore'
cassandra = require 'node-cassandra-cql'

AbstractContainer = require './AbstractContainer'

class CassandraContainer extends AbstractContainer
  constructor: (@app, @options) ->
    @client = new cassandra.Client
      hosts: @options.server_list,
      keyspace: @options.keyspace

    # @client.on 'log', (level, message) =>
      # @app.log[level] "cassandra.client: #{message}"

    @client.on 'err', (err) =>
      @app.log.error "cassandra.client: #{err}"

  stop: ->
    @app.log.warn "Shuting down cassandra container"
    @client.shutdown () =>
      @app.log.info "CassandraContainer::shutdown complete"

  _load: (key, cb) ->
    console.log key
    key = key.replace /-/g, ''
    @client.execute 'SELECT events FROM ids WHERE hash = ?', [key], (err, results) =>
      if err?
        @app.log.error "SELECT -key was: #{key} #{typeof key}- #{err}"
        return cb null
      if results? and results.rows.length
        console.log results.rows[0].get 'events'
        return cb JSON.parse results.rows[0].get 'events'
      else
        return cb []

  _append: (key, value, data, cb) ->
    data = [] unless data?
    data.push value
    # TODO: filter duplicates ??
    data = _.uniq data , false, (item) -> JSON.stringify item
    console.log JSON.stringify data
    @client.execute 'INSERT INTO ids (hash,events) VALUES (?,?)', [key, JSON.stringify data], (err) =>
      if err?
        @app.log.error "INSERT: #{err}"
        return cb null
      return cb data


module.exports = CassandraContainer
