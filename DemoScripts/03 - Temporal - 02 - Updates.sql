-- 5/6/2017 by Allison Benneth (allison at sqltran dot org)
-- Feel free to use in any way you would like.

use Manufacturing;
go

-- Update some rows and delete something.
update Inventory
set QuantityOnHand = QuantityOnHand - 3
where ProductID >= 10
and ProductID % 3 = 0;

delete Inventory where ProductID = 17;

-- Check again (and fix the table name for ProductionOutput history)
select * from MSSQL_TemporalHistoryFor_565577053;
select * from InventoryHistory;
-- Note that the history table contains the "before" image of the row.
-- Note the timestamps.

-- Query the data as of the original insert.
-- Replace the time below with a time that falls between ProductID 12 and ProductID 13
select *
from Inventory for system_time as of '2017-04-28 14:56:00'
order by ProductID;

-- How about for a time before the initial insert (even before the table was created!)?
select *
from Inventory for system_time as of '2017-01-01 0:00:00'
order by ProductID;

-- Do an insert into ProductionOutput table and a related update to Inventory table 
-- within a single transaction.  Wait 5 seconds between these operations.
begin transaction;

insert ProductionOutput (ProductID, ProductionDate, Quantity)
values (1, '2017-05-06', 42);

waitfor delay '0:00:05';

update Inventory
set QuantityOnHand += 42
where ProductID = 1;

commit transaction;

-- Look at the timestamps.  SQL server uses the time as of the begin of the transaction
-- to generate transactionally consistent results.
select *
from ProductionOutput;

select *
from Inventory
where ProductID = 1;

select *
from InventoryHistory
where ProductID = 1;
