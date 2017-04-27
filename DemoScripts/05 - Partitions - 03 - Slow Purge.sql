declare @RangeStart datetime2 = '0001-01-01';
declare @RangeEnd datetime2;

select top 1 @RangeStart = StartTime
from ProductHistory
order by EndTime, StartTime;

select @RangeEnd = StartTime
from ProductHistory
order by EndTime, StartTime
offset 5000 rows
fetch next 1 row only;

begin transaction

insert ProductArchive (ProductID, CurrentPrice, StartTime, EndTime)
select ProductID, CurrentPrice, StartTime, EndTime
from ProductHistory
where StartTime >= @RangeStart
and StartTime < @RangeEnd;

delete ProductHistory
where StartTime >= @RangeStart
and StartTime < @RangeEnd;

rollback;
alter table Product set (system_versioning = on);
alter table Product set (system_versioning = off);
