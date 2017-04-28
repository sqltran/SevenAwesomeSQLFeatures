-----------------------------------------------------------------------------------------------------------------------
-- Hekaton: Create database
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2015, Allison Benneth (allison@sqltran.org).
-- Feel free to use this code in any way you see fit, but do so at your own risk
-----------------------------------------------------------------------------------------------------------------------
use master;
go;
-- Create the database and enable Hekaton.
-- Note that we have to add a separate filegroup and specify 'contains memory_optimized_data'.
-- The 'filename' target of the in-memory filegroup is actually a directory name.
-- It is recommended that the in-memory filegroup contain an EVEN number of directories
-- (this is for perforance reasons based on the internal workings of Hekaton).
-- Naturally, all of the path names will need to be modified to suit your environment.

drop database if exists InMemoryDb;

create database InMemoryDB
on primary (name = 'InMemoryDb', filename = 'c:\data\Express2016SP1\data\InMemoryDb.mdf'),
filegroup InMemoryDbFG contains memory_optimized_data
(name = InMemoryDbFS, filename = 'c:\data\Express2016SP1\data\InMemoryDbFS1'),
(name = InMemroyDbFS, filename = 'c:\data\Express2016SP1\data\InMemoryDbFS2')
log on (name = 'InMemoryDb_log', filename = 'c:\data\Express2016SP1\log\InMemoryDb_log.ldf');
