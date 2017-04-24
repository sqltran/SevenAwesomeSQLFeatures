-- Must specify a filename to store the snapshot data
create database CompanyHRSnapshot
on (name = 'CompanyHR', filename = 'c:\data\CompanyHR.ss')
as snapshot of CompanyHR;
go

-- Make a data change to the source database.
select * from CompanyHR.dbo.Employee where LoginName = 'eadkins';
exec CompanyHR.dbo.upUpdateEmployeeSalary 'eadkins', 67890.00;

-- The update is reflected in the source database, but the snapshot still contains the original value
select * from CompanyHR.dbo.Employee where LoginName = 'eadkins';
select * from CompanyHRSnapshot.dbo.Employee where LoginName = 'eadkins';

-- The snapshot is read-only
exec CompanyHRSnapshot.dbo.upUpdateEmployeeSalary 'eadkins', 67890.00;
--Msg 3906, Level 16, State 1, Procedure upUpdateEmployeeSalary, Line 7 [Batch Start Line 15]
--Failed to update database "CompanyHRSnapshot" because the database is read-only.
