-- 5/6/2017 by Allison Benneth (allison at sqltran dot org)
-- Feel free to use in any way you would like.

use master;
go
-- Create the database and enable Hekaton.
-- Note that we have to add a separate filegroup and specify 'contains memory_optimized_data'.
-- The 'filename' target of the in-memory filegroup is actually a directory name.
-- It is recommended that the in-memory filegroup contain an EVEN number of directories
-- (this is for perforance reasons based on the internal workings of Hekaton).
-- Naturally, all of the path names will need to be modified to suit your environment.

--alter database InMemoryDb set offline with rollback immediate;
--alter database InMemoryDb set online with rollback immediate;

drop database if exists InMemoryDb;

create database InMemoryDB
on primary (name = 'InMemoryDb', filename = 'c:\data\Express2016SP1\data\InMemoryDb.mdf'),
filegroup InMemoryDbFG contains memory_optimized_data
(name = InMemoryDbFS, filename = 'c:\data\Express2016SP1\data\InMemoryDbFS1'),
(name = InMemroyDbFS, filename = 'c:\data\Express2016SP1\data\InMemoryDbFS2')
log on (name = 'InMemoryDb_log', filename = 'c:\data\Express2016SP1\log\InMemoryDb_log.ldf');
