-- create the database
CREATE KEYSPACE ks_staging
    WITH placement_strategy = 'org.apache.cassandra.locator.NetworkTopologyStrategy'
    AND strategy_options = {eu-west:2}
;

USE ks_staging
;

-- create the tables
CREATE COLUMN FAMILY ids
    WITH comparator = TimeUUIDType
;
