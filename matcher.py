#!/usr/bin/env python

"""
    This is a refenrece implementation of a simple string matching algorithm
    using python string matching. This is not about a fast implementation of
    string matching but more a proof of concept for scalable and high-available
    string matching using a scalable and high-available database
                            - Apache Cassandra -
"""

import argparse
from subprocess import Popen, PIPE
import time
import traceback
from uuid import uuid1

import pycassa
import ujson as json
import MySQLdb

def read_arguments():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config', '-c', required=True)
    p.add_argument('--container', '-t', required=True,
                   choices=['MemoryContainer', 'CassandraContainer'])
    return p.parse_args()

class AbstractContainer(object):
    ''' Abstraction layer to interact with strings in a containers '''
    def _load(key):
        raise NotImplementedError
    def _append(key, value, data):
        raise NotImplementedError

    def check(self, key, value):
        data = self._load(key)
        if value not in data:
            self._append(key, value, data)
        return data

# memory structure to match in memory
class MemoryContainer(AbstractContainer):
    ''' Abstraction layer to interact with strings in a containers '''
    def __init__(self):
        self.container = {}

    def _load(key):
        if key not in self.container:
            self.container[key] = list()
        return self.container[key]

    def _append(key, value, data):
        self.container[key].append(value)
        return self.container[key]

# class MysqlContainer(object):
#     ''' Abstraction layer to interact with strings in a containers '''
#     def __init__(self, mysql_opts):
#         self.con = MySQLdb.connection(**mysql_opts)

#     def _load(key):
#         c = self.con.cursor()
#         c.execute(" SELECT index, value FROM ids WHERE key = ? ", [key])
#         data = list()
#         for (index, value) in c.fetchall():
#             data.append(tuple(json.loads(value)))
#         return data

#     def _append(key, value, data):
#         data.append(value)
#         i = 0
#         d = {}
#         for value in data:
#             d[str(i)] = json.dumps(value)
#             i += 1
#         self.con.insert(key, d)

class CassandraContainer(AbstractContainer):
    ''' Abstraction layer to interact with strings in a containers '''
    def __init__(self, keyspace, server_list, cf):
        self.pool = pycassa.pool.ConnectionPool(keyspace, server_list, timeout=None)
        self.con = pycassa.columnfamily.ColumnFamily(self.pool, cf)

    def _load(key):
        data = list()
        for _, value in self.con.xget(key):
            data.append(tuple(json.loads(value)))
        return data

    def _append(key, value, data):
        data.append(value)
        i = 0
        d = {}
        for value in data:
            d[str(i)] = json.dumps(value)
            i += 1
        self.con.insert(key, d)
        return data

def x_read_events(files):
    ''' Reads the events '''
    for filename in files:
        with open(filename) as f:
            for line in f:
                try:
                    yield json.loads(line)
                except Exception as _e:
                    print 'ERR:', _e

class Matcher(object):
    """
        Class to match incoming events against each other
    """
    def __init__(self, container, tracked_ids, hex_lens):
        self.container = container
        self.tracked_ids = tracked_ids
        self.hex_lens = hex_lens

    def ignore_event(self, event):
        if 'campaign' in event and int(event['campaign']) in [1,2]:
            return True

    def get_tracked_fields(self, event):
        fields = {}
        # get all tracked fields
        for tracked in self.tracked_ids:
            id_value = event[tracked] if tracked in event else ''

            # filter crappy ids
            if len(id_value) not in self.hex_lens: continue

            fields[tracked] = event[tracked]
        return fields

    def on_event(self, event):
        try:
            # filter test events
            if self.ignore_event(event): return

            # get the static fields to compare events later on
            aid = event['actionId']
            etype = int(event['TMEvent'])
            etime = int(event['TMTimeEvent'])
            data = (aid, etype, etime)

            # get all tracked fields
            tracked = self.get_tracked_fields(event)

            # try to match
            matches = []
            match_type = 13 if etype == 14 else 14
            for id_name, id_value in tracked.iteritems():
                stored = data + (id_name,)
                id_set = self.container.check(id_value, stored)
                if len(id_set) > 1:
                    # find whether this was an event match
                    matches = [x for x in id_set if x[1] == match_type]
                    if matches:
                        print stored, id_value, matches

        except Exception as _e:
            print 'ERR:', _e
            print traceback.format_exc()


def main(args):
    # load config
    with open(args.config) as f:
        config = json.load(f)

    # the container to store all the ids
    container = globals()[args.container](**config[args.container])

    # the matcher
    matcher = Matcher(container, **config['matcher'])

    for event in x_read_events(config['files']):
        matcher.on_event(event)

if __name__ == '__main__':
    t1 = time.time()
    args = read_arguments()
    main(args)
    p = Popen(['ps aux | grep string_matching'], shell=True)
    print time.time() - t1
