use PersonDW;
go
set statistics io on;
set statistics time on;

-- How much space is the current row-based clustered index using?
exec sp_spaceused 'PersonDim';
-- Data size = 104832 KB

select *
from PersonDim pd
where pd.State = 'TN';
-- Check output on messages tab.  Requires 13154 logical reads to satisfy the query.

-- Does adding a non-clustered row index help that?
create index ix1_PersonDim__State on PersonDim (State);

select *
from PersonDim pd
where pd.State = 'TN';
-- No, still requires 13154 logical reads.  The selectivity of the requested data is sufficiently large that the nonclustered index doesn't help amd isn't used.

drop index PersonDim.ix1_PersonDim__State;

-- Convert to columnstore index.

alter table PersonDim drop constraint pk_PersonDim;
create clustered columnstore index cci_PersonDim on PersonDim;

exec sp_spaceused 'PersonDim';
-- Data size = 5696 KB  ==> 18x compression!

select *
from PersonDim pd
where pd.State = 'TN';
-- Now requires only 1475 logical reads.

create nonclustered columnstore index nci_PersonDim__Stage on PersonDim (State);
-- Error, can only create one columnstore index per table
-- Msg 35339, Level 16, State 1, Line 38
-- Multiple columnstore indexes are not supported.

alter index cci_PersonDim on PersonDim rebuild with (data_compression = columnstore_archive);

exec sp_spaceused 'PersonDim';
-- Data size = 5400 KB  -- got a bit better compression

select *
from PersonDim pd
where pd.State = 'TN';
-- Now requires 1354 logical reads.

select PersonId, FirstName, LastName
from PersonDim pd
where pd.State = 'TN';
-- Limiting the number of columns cuts down the I/O as well - 870 logical reads.
