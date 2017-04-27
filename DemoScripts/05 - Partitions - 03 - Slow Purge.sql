use Sales;
go
select 'Product' TableName, count(*) NbrRows from Product
union all
select 'ProductHistory' TableName, count(*) NbrRows from ProductHistory
union all
select 'ProductArchive' TableName, count(*) NbrRows from ProductArchive;

----------------------------------------------------------------------------------------------------
-- Here is the general strategy.  However, this will fail because deletes are not allowed from
-- the ProductHistory table while system versioning is enabled on Product.
----------------------------------------------------------------------------------------------------
begin transaction

insert ProductArchive (ProductID, CurrentPrice, StartTime, EndTime)
select ProductID, CurrentPrice, StartTime, EndTime
from ProductHistory
where StartTime < '2017-02-01';

delete ProductHistory
where StartTime < '2017-02-01';

rollback;
go

----------------------------------------------------------------------------------------------------
-- So what we really need to do is to temporarily disable system versioning on Product while
-- the delete is in progress.
--
-- However, what if some process comes along and modifies Product while it is disabled?  The 
-- corresponding history gets lost. To avoid this, we will (within a single transaction)
-- (a) disable system versioning, (b) perform the delete, and (c) enable system versioning. 
-- This effectively locks the Product table and blocks other user activity.
--
-- But what if the delete is millions of rows?  Users get blocked for extended periods of
-- time.  How to do this without a maintenance window?  Break the archival process into
-- small chunks of rows and repeat the process many times.
----------------------------------------------------------------------------------------------------
declare @RangeStart datetime2;
declare @RangeEnd datetime2 = '0001-01-01';

while @RangeEnd < '2017-02-01'
begin
	select top 1 @RangeStart = StartTime
	from ProductHistory
	order by EndTime, StartTime;

	select @RangeEnd = StartTime
	from ProductHistory
	order by EndTime, StartTime
	offset 5000 rows
	fetch next 1 row only;

	if @RangeEnd > '2017-02-01'
	begin
		set @RangeEnd = '2017-02-01';
	end;

	declare @offSql nvarchar(max) = 'alter table Product set (system_versioning = off);';
	declare @insertSql nvarchar(max) = 'insert ProductArchive (ProductID, CurrentPrice, StartTime, EndTime)
		select ProductID, CurrentPrice, StartTime, EndTime
		from ProductHistory
		where StartTime > ''' + cast(@RangeStart as nvarchar(30)) + ''' and StartTime <= ''' + cast(@RangeEnd as nvarchar(30)) + ''';';
	declare @deleteSql nvarchar(max) = 'delete ProductHistory
		where StartTime > ''' + cast(@RangeStart as nvarchar(30)) + ''' and StartTime <= ''' + cast(@RangeEnd as nvarchar(30)) + ''';';
	declare @onSql nvarchar(max) = 'alter table Product set (system_versioning = on (history_table = dbo.ProductHistory, data_consistency_check = off));';

	begin transaction;
		exec (@offSql);
		exec (@insertSql);
		exec (@deleteSql);
		exec (@onSql);
	commit transaction;
end;

select 'Product' TableName, count(*) NbrRows from Product
union all
select 'ProductHistory' TableName, count(*) NbrRows from ProductHistory
union all
select 'ProductArchive' TableName, count(*) NbrRows from ProductArchive;

go

-- Reset to an earlier stage in preparation for partitioning demo
alter database Sales set offline with rollback immediate;
restore database Sales from disk = 'Sales.bak' with replace;
