-- 5/6/2017 by Allison Benneth (allison at sqltran dot org)
-- Feel free to use in any way you would like.

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

-- Querying an in-memory table.
select *
from dbo.Product;

-- However, inside an explicit transaction, we run into a problem.
begin transaction;

select *
from dbo.Product;

commit transaction;
--Msg 41368, Level 16, State 0, Line 40
--Accessing memory optimized tables using the READ COMMITTED isolation level is supported only for autocommit transactions. It is not supported for explicit or implicit transactions. Provide a supported isolation level for the memory optimized table using a table hint, such as WITH (SNAPSHOT).

-- Try again at snapshot isolation level.
-- (Can also run at repeatable_read or serializable isolation level.)
begin transaction;

select *
from dbo.Product with (snapshot);

commit transaction;

-- Database-level option to avoid the need for this.
alter database InMemoryDB set memory_optimized_elevate_to_snapshot on;

begin transaction;

select *
from dbo.Product;

commit transaction;
