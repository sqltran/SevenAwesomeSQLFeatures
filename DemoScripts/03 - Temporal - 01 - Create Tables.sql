-- 5/6/2017 by Allison Benneth (allison at sqltran dot org)
-- Feel free to use in any way you would like.

-- use master;
-- go
-- alter database Manufacturing set offline with rollback immediate;
-- alter database Manufacturing set online with rollback immediate;
-- drop database if exists Manufacturing;
use master;
go
create database Manufacturing;
go
use Manufacturing;
go
drop table if exists ProductionOutput;

create table ProductionOutput
(
	ProductionOutputID int not null identity(1,1),
	ProductID int not null,
	ProductionDate date not null,
	Quantity int not null,
	ValidFrom datetime2 generated always as row start not null,
	ValidTo datetime2 generated always as row end not null,
	period for system_time (ValidFrom, ValidTo),
	constraint pk_ProductionOutput primary key clustered (ProductionOutputID)
) with (system_versioning = on);

select t.name source_table_name, t.temporal_type_desc, ht.name history_table_name
from sys.tables t
inner join sys.tables ht on t.history_table_id = ht.object_id
where t.name = 'ProductionOutput';

drop table if exists InventoryHistory;

create table InventoryHistory
(
	ProductID int not null,
	QuantityOnHand int not null,
	ValidFrom datetime2 not null,
	ValidTo datetime2 not null
);

create clustered index ix1_InventoryHistory on InventoryHistory (ValidTo, ValidFrom);

drop table if exists Inventory;

create table Inventory
(
	ProductID int not null,
	QuantityOnHand int not null,
	ValidFrom datetime2 generated always as row start not null,
	ValidTo datetime2 generated always as row end not null,
	period for system_time (ValidFrom, ValidTo),
	constraint pk_Inventory primary key clustered (ProductID)
) with (system_versioning = on (history_table = dbo.InventoryHistory));

select t.name source_table_name, t.temporal_type_desc, ht.name history_table_name
from sys.tables t
inner join sys.tables ht on t.history_table_id = ht.object_id
where t.name = 'Inventory';

go

with l0 as (select 1 v union all select 1), l1 as (select a.v from l0 a, l0), l2 as (select a.v from l1 a, l1),
l3 as (select a.v from l2 a, l2), l4 as (select a.v from l3 a, l3), l5 as (select a.v from l4 a, l4),
nums as (select row_number() over (order by (select null)) n from l5)
insert Inventory (ProductID, QuantityOnHand)
select n.n, n.n
from nums n
where n.n <= 20;

select *
from Inventory
order by ProductID;
-- Things to note:  ValidFrom is automatically set to the current UTC time;
-- ValidTo is automatically set to the end of time.

-- Anything in history yet?  (Fix the name of the ProductionOutput history table.)
select * from MSSQL_TemporalHistoryFor_565577053;
select * from InventoryHistory;
-- Note that inserts do not add to the history table.
