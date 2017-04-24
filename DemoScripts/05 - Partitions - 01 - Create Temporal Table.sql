--drop database if exists Sales;
--go
--create database Sales;
--go
use Sales;
go

--drop partition scheme schemeProductHistoryPartitionByEndTime;
--drop partition function fnProductHistoryPartitionByEndTime;

create partition function fnProductHistoryPartitionByEndTime (datetime2)
as range left for values ('2017-01-01', '2017-02-01', '2017-03-01', '2017-04-01', '2017-05-01');

create partition scheme schemeProductHistoryPartitionByEndTime
as partition fnProductHistoryPartitionByEndTime
to ([primary], [primary], [primary], [primary], [primary], [primary]);

create table ProductHistory
(
	ProductID int not null,
	CurrentPrice money not null,
	StartTime datetime2(7) not null,
	EndTime datetime2(7) not null
);

create clustered index clidx_ProductHistory on ProductHistory (EndTime, StartTime)
on schemeProductHistoryPartitionByEndTime (EndTime);

create table Product
(
	ProductID int not null identity(1,1),
	CurrentPrice money not null,
	StartTime datetime2 generated always as row start,
	EndTime datetime2 generated always as row end,
	period for system_time (StartTime, EndTime),
	constraint pk_Product primary key clustered (ProductID)
) with (system_versioning = on (history_table = dbo.ProductHistory));

--alter table Product set (system_versioning = off);
--drop table Product;
--drop table ProductHistory;

-- Initial populate of Product table
with l0 as (select 1 v union all select 1), l1 as (select a.v from l0 a, l0), l2 as (select a.v from l1 a, l1),
l3 as (select a.v from l2 a, l2), l4 as (select a.v from l3 a, l3), l5 as (select a.v from l4 a, l4),
nums as (select row_number() over (order by (select null)) n from l5)
insert Product (CurrentPrice)
select cast(n.n as money) CurrentPrice
from nums n
where n.n <= 1000;
