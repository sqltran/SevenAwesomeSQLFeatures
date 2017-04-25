-- We're going to fake temporal history by loading into the ProductHistory table while it is in a "detached"
-- state from the Product table, then later connect the two.

use Sales;
go
declare @ProductID int;
declare @ChangePercent float;
declare @ChangeTime datetime2 = '2017-01-01';

while @ChangeTime < '2017-04-24'
begin
	select top 1 @ProductID = ProductID
	from Product
	order by newid();

	select @ChangePercent = 0.5 - (binary_checksum(newid()) + 2147483648.) / 4294967296.;

	insert ProductHistory (ProductID, CurrentPrice, StartTime, EndTime)
	select ProductID, CurrentPrice, StartTime, @ChangeTime
	from Product
	where ProductID = @ProductID;

	update Product
	set CurrentPrice += CurrentPrice * @ChangePercent,
		StartTime = @ChangeTime
	where ProductID = @ProductID;

	select @ChangeTime = dateadd(second, 60, @ChangeTime);
	select @ChangeTime = dateadd(millisecond, @ChangePercent * 1000, @ChangeTime);
	select @ChangeTime = dateadd(nanosecond, @ChangePercent * 1001001, @ChangeTime);
end

alter table Product
add period for system_time (StartTime, EndTime);

alter table Product
set (system_versioning = on (history_table = dbo.ProductHistory));
