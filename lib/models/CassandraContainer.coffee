# -- coffee --

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
