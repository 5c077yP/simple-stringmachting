# -- coffee --

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
