-----------------------------------------------------------------------------------------------------------------------
-- Hekaton: Create table
-----------------------------------------------------------------------------------------------------------------------
-- Copyright 2015, Allison Benneth (allison@sqltran.org).
-- Feel free to use this code in any way you see fit, but do so at your own risk
-----------------------------------------------------------------------------------------------------------------------
use InMemoryDb;

-- Table creation is similar to disk-based tables.  However, indexes must be declared at
-- creation time.  We will add a primary key hash index on ProductID.  We will also have
-- a range index on UnitPrice (note that range indexes simply use the "index" keyword -- there
-- is not a "range" keyword).

drop table if exists dbo.Product;

create table dbo.Product
(
	ProductID int not null,
	Description nvarchar(500) not null,
	UnitPrice money not null,

	primary key nonclustered hash (ProductID) with (bucket_count = 1048576),
	index idx_Product__UnitPrice nonclustered (UnitPrice)
) with (memory_optimized = on, durability = schema_and_data);

-- Populate a few rows into the table

insert dbo.Product (ProductID, Description, UnitPrice)
values (1, 'Gizmo', 34.00),
	(2, 'Whatzit', 16.00);
