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

readEvents = (filenames) ->
  filenames.forEach (filename) ->
    ll(fs.createReadStream(filename)).forEach (line) ->
      console.log line



# def x_read_events(files):
#   ''' Reads the events '''
#   for filename in files:
#     with open(filename) as f:
#       for line in f:
#         try:
#           yield json.loads(line)
#         except Exception as _e:
#           print 'ERR:', _e

# class Matcher(object):
#   """
#     Class to match incoming events against each other
#   """
#   def __init__(self, container, tracked_ids, hex_lens):
#     self.container = container
#     self.tracked_ids = tracked_ids
#     self.hex_lens = hex_lens

#   def ignore_event(self, event):
#     if 'campaign' in event and int(event['campaign']) in [1,2]:
#       return True

#   def get_tracked_fields(self, event):
#     fields = {}
#     # get all tracked fields
#     for tracked in self.tracked_ids:
#       id_value = event[tracked] if tracked in event else ''

#       # filter crappy ids
#       if len(id_value) not in self.hex_lens: continue

#       fields[tracked] = event[tracked]
#     return fields

#   def on_event(self, event):
#     try:
#       # filter test events
#       if self.ignore_event(event): return

#       # get the static fields to compare events later on
#       aid = event['actionId']
#       etype = int(event['TMEvent'])
#       etime = int(event['TMTimeEvent'])
#       data = (aid, etype, etime)

#       # get all tracked fields
#       tracked = self.get_tracked_fields(event)

#       # try to match
#       matches = []
#       match_type = 13 if etype == 14 else 14
#       for id_name, id_value in tracked.iteritems():
#         stored = data + (id_name,)
#         id_set = self.container.check(id_value, stored)
#         if len(id_set) > 1:
#           # find whether this was an event match
#           matches = [x for x in id_set if x[1] == match_type]
#           if matches:
#             print stored, id_value, matches

#     except Exception as _e:
#       print 'ERR:', _e
#       print traceback.format_exc()



readEvents nconf.get('files').split(','), (event) ->
  console.log event

# the container to store all the ids
container = new MemoryContainer()

# # the matcher
# matcher = Matcher(container, **config['matcher'])

# for event in x_read_events(config['files']):
#   matcher.on_event(event)


