-- create the database
CREATE DATABASE IF NOT EXISTS `db_stage`
  CHARACTER SET utf8
;

USE `db_stage`
;

-- create the tables
CREATE TABLE IF NOT EXISTS `ids` (
  `key` varchar(255) NOT NULL,
  `time_uuid` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
) ENGINE=MyISAM DEFAULT CHARSET=utf8
;
