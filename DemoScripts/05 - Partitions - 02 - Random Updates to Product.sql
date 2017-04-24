use Sales;
go
declare @ProductID int;
declare @ChangePercent float;

while 0 = 0
begin
	select top 1 @ProductID = ProductID
	from Product
	order by newid();

	select @ChangePercent = 0.5 - (binary_checksum(newid()) + 2147483648.) / 4294967296.;

	update Product
	set CurrentPrice += CurrentPrice * @ChangePercent
	where ProductID = @ProductID;

	waitfor delay '0:00:01';
end
