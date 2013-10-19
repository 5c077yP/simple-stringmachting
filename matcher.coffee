#!/usr/bin/env coffee

###
  This is a refenrece implementation of a simple string matching algorithm
  using nodejs/coffee-script. This is not about a fast implementation of
  string matching but more a proof of concept for scalable and high-available
  string matching using a scalable and high-available database
                       - Apache Cassandra -
###

fs = require 'fs'

_ = require 'underscore'
async = require 'async'
nconf = require 'nconf'
ll = require 'lazy-lines'

nconf.argv
  f:
    alias: ['f', 'files'],
    demand: true
    describe: 'comma separated list of file names that are parsed'
  t:
    alias: 'container',
    default: 'memory',
    describe: 'the container class used'
  c:
    alias: 'config',
    demand: true,
    describe: '/path/to/config/json'

nconf.file
  file: nconf.get 'config'


class AbstractContainer
  _load: (key) ->
    throw new Error "Not implemented"
  _append: (key, value, data) ->
    throw new Error "Not implemented"

  check: (key, value) ->
    data = @_load key
    data = @_append key, value, data if value not in data
    return data

class MemoryContainer extends AbstractContainer
  contructor: ->
    @container = {}
  _load: (key) ->
    @container[key] = [] unless @container[key]?
    return @container[key]
  _append: (key, value, data) ->
    @container[key].push value
    return @container[key]

# class MysqlContainer(object):
#   ''' Abstraction layer to interact with strings in a containers '''
#   def __init__(self, mysql_opts):
#     self.con = MySQLdb.connection(**mysql_opts)

#   def _load(key):
#     c = self.con.cursor()
#     c.execute(" SELECT time_uuid, value FROM ids WHERE key = ? ", [key])
#     data = list()
#     for (_, value) in c.fetchall():
#       data.append(tuple(json.loads(value)))
#     return data

#   def _append(key, value, data):
#     data.append(value)
#     time_uuid = uuid.uuid1().bytes.encode('base64').rstrip('=\n').replace('/', '_')
#     c.execute(" INSERT INTO ids (key, time_uuid, value) VALUES (?, ?, ?) ", [key, time_uuid, json.dumps(value)])
#     return data

# class CassandraContainer(AbstractContainer):
#   ''' Abstraction layer to interact with strings in a containers '''
#   def __init__(self, keyspace, server_list, cf):
#     self.pool = pycassa.pool.ConnectionPool(keyspace, server_list, timeout=None)
#     self.con = pycassa.columnfamily.ColumnFamily(self.pool, cf)

#   def _load(self, key):
#     data = list()
#     for _, value in self.con.xget(key):
#       data.append(tuple(json.loads(value)))
#     return data

#   def _append(self, key, value, data):
#     data.append(value)
#     time_uuid = pycassa.util.convert_time_to_uuid(datetime.utcnow())
#     self.con.insert(key, {time_uuid: json.dumps(value)})
#     return data

readEvents = (filenames, cb) ->
  filenames.forEach (filename) ->
    ll(fs.createReadStream(filename)).forEach (line) ->
      try
        cb JSON.parse line
      catch e
        console.log "ERR -> #{e}"

class Matcher
  contructor: (@container, @trackedIds, @hexLens) ->

  _ignoreEvents: (event) ->
    return true if event['campaign']? and 3 > parseInt event['campaign'], 10

  _getTrackedFields: (event) ->
    fields = {}
    for tracked of @trackedIds
      continue unless event[tracked]?
      continue unless event[tracked].length in @hexLens
      fields[tracked] = event[tracked]
    return fields

  onEvent: (event) ->
    try
      # filter test events
      return if @_ignoreEvents event

      # get the static fields to compare events later on
      aid = event['actionId']
      etype = parseInt event['TMEvent'], 10
      etime = parseInt event['TMTimeEvent'], 10
      data = [aid, etype, etime]

      # get all tracked fields
      tracked = @_getTrackedFields event

      # try to match
      matches = []
      matchType = if etype == 14 then 13 else 14
      for idName, idValue of tracked
        stored = data.concat [idName]
        idSet = @container.check idValue, stored
        if idSet.length > 1
          # find whether this was an event match
          matches = _.filter idSet, (d) -> d[1] == matchType
          if matches.length
            console.log stored, idValue, matches
    catch e
      console.log "ERR: #{e}"


# the container to store all the ids
container = new MemoryContainer()

# the matcher
matcher = new Matcher container, nconf.get('matcher')['tracked_ids'], nconf.get('matcher')['hex_lens']

readEvents nconf.get('files').split(','), (event) ->
  matcher.onEvent event
