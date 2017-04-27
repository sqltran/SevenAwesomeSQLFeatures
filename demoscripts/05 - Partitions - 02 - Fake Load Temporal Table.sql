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

create table Product
(
	ProductID int not null identity(1,1),
	CurrentPrice money not null,
	StartTime datetime2 generated always as row start,
	EndTime datetime2 generated always as row end,
	period for system_time (StartTime, EndTime),
	constraint pk_Product primary key clustered (ProductID)
) with (system_versioning = on (history_table = dbo.ProductHistory));

set identity_insert Product on;

insert Product (ProductId, CurrentPrice)
select ProductId, CurrentPrice
from TempProduct;

set identity_insert Product off;

drop table TempProduct;




backup database Sales to disk = 'Sales.bak' with init;

use master;
go
alter database Sales set offline with rollback immediate;
go
restore database Sales from disk = 'Sales.bak' with replace;

insert Product (CurrentPrice)
values (54.00);

select scope_identity();

update Product
set CurrentPrice = 55.00
where ProductID = 1002;