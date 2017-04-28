-----------------------------------------------------------------------------------------------------------------------
-- Hekaton: Native compilation of stored procedures
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2015, Allison Benneth (allison@sqltran.org).
-- Feel free to use this code in any way you see fit, but do so at your own risk
-----------------------------------------------------------------------------------------------------------------------
use InMemoryDB;

-- With a whole lot of limitations, stored procedures can be compiled into native machine code as a DLL that
-- SQL Server will load and execute when the procedure is called.

drop procedure if exists usp_UpdateProduct;
go
create procedure dbo.usp_UpdateProduct (@ProductID int, @NewUnitPrice money)
with native_compilation, schemabinding, execute as owner
as
begin atomic with (transaction isolation level = snapshot, language = 'us_english')
	update dbo.Product
	set UnitPrice = @NewUnitPrice
	where ProductID = @ProductID;
end

go

-- The procedure can be called in the traditional fashion.

select ProductID, Description, UnitPrice from dbo.Product where ProductID = 1;

exec dbo.usp_UpdateProduct @ProductID = 1, @NewUnitPrice = 42.00;

select ProductID, Description, UnitPrice from dbo.Product where ProductID = 1;
go

drop procedure if exists usp_CreateNewRecords;
go
create procedure dbo.usp_CreateNewRecords (@RecordCount int)
with native_compilation, schemabinding, execute as owner
as
begin atomic with (transaction isolation level = snapshot, language = 'us_english')
    declare @firstId int;
    select @firstId = isnull(max(ProductID), 0) from dbo.Product;
 
    declare @counter int = 1;
    while @counter <= @RecordCount
    begin
        insert dbo.Product (ProductID, Description, UnitPrice)
        values (@firstId + @counter,
            'Product ' + cast(@firstId + @counter as nvarchar(500)),
            cast(@firstId + @counter as money));
        select @counter = @counter + 1;
    end
end
go

exec dbo.usp_CreateNewRecords @RecordCount = 1000000;
