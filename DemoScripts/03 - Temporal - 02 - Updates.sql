use CompanyHR_SV;
go
-- Make updates to Employees

declare empcsr cursor fast_forward
for
select LoginName, Salary
from Employee;

declare @LoginName sysname;
declare @Salary money;

open empcsr;
fetch next from empcsr into @LoginName, @Salary;
while @@fetch_status = 0
begin
	declare @NewSalary money = @Salary * 1.05;
	exec upUpdateEmployeeSalary @LoginName, @NewSalary;
	waitfor delay '0:00:00.010';
	fetch next from empcsr into @LoginName, @Salary;
end;

close empcsr;
deallocate empcsr;

-- Check state of EmployeeHistory
select * from EmployeeHistory;
