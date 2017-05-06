-- 5/6/2017 by Allison Benneth (allison at sqltran dot org)
-- Feel free to use in any way you would like.

-- We're going to fake temporal history by loading into the ProductHistory table while it is in a "detached"
-- state from the Product table, then later connect the two.

use Sales;
go
declare @ProductID int;
declare @ChangeAmount float;
declare @ChangeTime datetime2 = '2017-01-01';

while @ChangeTime < '2017-04-24'
begin
	select top 1 @ProductID = ProductID
	from TempProduct
	order by newid();

	select @ChangeAmount = 0.5 - (binary_checksum(newid()) + 2147483648.) / 4294967296.;

	insert ProductHistory (ProductID, CurrentPrice, StartTime, EndTime)
	select ProductID, CurrentPrice, StartTime, @ChangeTime
	from TempProduct
	where ProductID = @ProductID;

	update TempProduct
	set CurrentPrice += @ChangeAmount,
		StartTime = @ChangeTime
	where ProductID = @ProductID;

	select @ChangeTime = dateadd(second, 60, @ChangeTime);
	select @ChangeTime = dateadd(millisecond, @ChangeAmount * 1000, @ChangeTime);
	select @ChangeTime = dateadd(nanosecond, @ChangeAmount * 1001001, @ChangeTime);
end

alter table Product set (system_versioning = on (history_table = dbo.ProductHistory, data_consistency_check = on));

set identity_insert Product on;

insert Product (ProductId, CurrentPrice)
select ProductId, CurrentPrice
from TempProduct;

set identity_insert Product off;

drop table TempProduct;


backup database Sales to disk = 'Sales.bak' with init;
