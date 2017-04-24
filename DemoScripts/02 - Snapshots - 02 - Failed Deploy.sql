-- Deploy a new stored proc that contains a nasty bug.
use CompanyHR;
go
alter procedure upUpdateEmployeeSalary
(
	@LoginName sysname,
	@NewSalary money
)
as
delete dbo.Employee
where LoginName = @LoginName;
go

select * from Employee where LoginName in ('jmonahan', 'jhalligan', 'sscott', 'cfloyd', 'hmays');

exec upUpdateEmployeeSalary 'jmonahan', 30120.00;
exec upUpdateEmployeeSalary 'jhalligan', 35258.00;
exec upUpdateEmployeeSalary 'sscott', 28470.00;
exec upUpdateEmployeeSalary 'cfloyd', 93331.00;
exec upUpdateEmployeeSalary 'hmays', 30180.00;

select * from Employee where LoginName in ('jmonahan', 'jhalligan', 'sscott', 'cfloyd', 'hmays');
go


-- Revert to snapshot
use master;
go
alter database CompanyHR set offline with rollback immediate;
alter database CompanyHR set online with rollback immediate;
go
restore database CompanyHR
from database_snapshot = 'CompanyHRSnapshot';
go

-- Check that original values have been restored and that stored procedure is reverted.
use CompanyHR;
go
select * from Employee where LoginName in ('jmonahan', 'jhalligan', 'sscott', 'cfloyd', 'hmays');
go
exec sp_helptext upUpdateEmployeeSalary;
go


-- Cleanup
drop database CompanyHRSnapshot;
go
