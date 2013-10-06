# simple-stringmatching

The ``simple-stringmatching`` tool is a benchmark to measure performance
differences of several database backends.

# Container

Containers are the abstract data types to have one single interface
but several database backends. To unify the results the basic idea of
the storage types should remain the same.

## Structure

The structure should always be the same. It's basically as simple as
a key-value store, but the value behind the key should be a list
of tuples.

### json-like strucutre

{
  "key1": [
    ["v11", "v12", ..., "v1i"],
    ["v21", "v22", ..., "v2i"],
    ...
    ["vj1", "vj2", ..., "vji"]
  ],
  ...
  "keyK": ...
}

## Container classes

* MemoryContainer
* CassandraContainer
* MysqlContainer

# TODOs
