-- 5/6/2017 by Allison Benneth (allison at sqltran dot org)
-- Feel free to use in any way you would like.

use Sales;
go
select 'Product' TableName, count(*) NbrRows from Product
union all
select 'ProductHistory' TableName, count(*) NbrRows from ProductHistory
union all
select 'ProductArchive' TableName, count(*) NbrRows from ProductArchive;

-- Now we'll move one partition at a time into the ProductArchive table.

begin transaction;

alter table dbo.ProductHistory
switch partition 1 to dbo.ProductArchive partition 1;

alter partition scheme schemeProductHistoryPartitionByEndTime
next used [primary];

-- Add a partition to the ProductHistory table for later inserts.
alter partition function fnProductHistoryPartitionByEndTime()
split range ('2017-06-01');

alter partition scheme schemeProductArchivePartitionByEndTime
next used [primary];

-- Add a partition to the ProductArchive table for data to be loaded in later.
alter partition function fnProductArchivePartitionByEndTime()
split range ('2017-04-01');

commit transaction;

select 'Product' TableName, count(*) NbrRows from Product
union all
select 'ProductHistory' TableName, count(*) NbrRows from ProductHistory
union all
select 'ProductArchive' TableName, count(*) NbrRows from ProductArchive;

----------------------------------------------------------------------------------------------------
-- One month later, repeat the process
----------------------------------------------------------------------------------------------------

begin transaction;

alter table dbo.ProductHistory
switch partition 2 to dbo.ProductArchive partition 2;

alter partition scheme schemeProductHistoryPartitionByEndTime
next used [primary];

alter partition function fnProductHistoryPartitionByEndTime()
split range ('2017-07-01');

alter partition scheme schemeProductArchivePartitionByEndTime
next used [primary];

alter partition function fnProductArchivePartitionByEndTime()
split range ('2017-05-01');

commit transaction;

select 'Product' TableName, count(*) NbrRows from Product
union all
select 'ProductHistory' TableName, count(*) NbrRows from ProductHistory
union all
select 'ProductArchive' TableName, count(*) NbrRows from ProductArchive;
