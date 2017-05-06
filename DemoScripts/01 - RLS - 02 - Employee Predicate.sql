-- 5/6/2017 by Allison Benneth (allison at sqltran dot org)
-- Feel free to use in any way you would like.

use CompanyHR;
go

-- HR Database with an employees table and a departments table.
select * from Employee;
select * from Department;

-- Initially, all users can see everything in the Employee table.
execute as user = 'jellis';  -- Customer service employee
select * from Employee;
revert;

-- Create a predicate to control security
-- We will allow a user to see:
-- (1) their own employee record, or
-- (2) if the user is a department leader, all records for the department's employees, or
-- (3) if the user is an HR employee, all records, or
-- (4) all records if the user is dbo (for demo purposes)

-- Best practice is to create a schema specifically for the user-defined function and related objects.
if not exists (select * from sys.schemas where name = 'Security')
	exec ('create schema Security');
go

drop security policy if exists EmployeeFilter;
drop function if exists Security.fnEmployeeRLSPredicate;
go
create function Security.fnEmployeeRLSPredicate(@LoginName sysname, @DepartmentCode varchar(5))
returns table with schemabinding
as
return
	with DepartmentLeaders as
	(
		select leader.LoginName, d.DepartmentCode
		from dbo.Department d
		inner join dbo.Employee leader on d.LeaderEmployeeID = leader.EmployeeID
	)
	select 1 as PredicateMatch
	from DepartmentLeaders dl
	where (dl.LoginName = user_name() collate SQL_Latin1_General_CP1_CI_AS and dl.DepartmentCode = @DepartmentCode)
	or @LoginName = user_name() collate SQL_Latin1_General_CP1_CI_AS
	or exists (select e.EmployeeID from dbo.Employee e where e.LoginName = user_name() collate SQL_Latin1_General_CP1_CI_AS and e.DepartmentCode = 'HR')
	or user_name() collate SQL_Latin1_General_CP1_CI_AS = 'dbo';
go

create security policy EmployeeFilter
add filter predicate Security.fnEmployeeRLSPredicate (LoginName, DepartmentCode)
on dbo.Employee
with (state = on);
go

-- If logged in as sysadmin, can see all records.
select * from Employee;

-- Non-department head can see only their own record
execute as user = 'jellis';  -- Customer service employee
select * from Employee;
revert;

-- Department head can see all records in their deparment
execute as user = 'rritenour';  -- IT leader
select * from Employee;
select * from Employee where DepartmentCode = 'CS';  -- No records: IT leader cannot see anything from customer service
revert;

-- HR employee can see all records
execute as user = 'tnichols';  -- HR employee, not leader
select * from Employee; -- Could modify to allow employee to see own record, all other non-HR records
select * from Employee where DepartmentCode = 'CS';  -- All CS records
revert;

-- What about updates?

-- Sysadmin can still delete, update, insert
begin transaction;
delete dbo.Employee where LoginName = 'jellis';
rollback transaction;
-- 1 row affected

begin transaction;
update dbo.Employee set DepartmentCode = 'IT' where LoginName = 'jellis';
rollback transaction;
-- 1 row affected

begin transaction;
insert dbo.Employee (FirstName, LastName, DepartmentCode, Salary, LoginName)
values ( N'Leonel', N'Hodd', 'IT', 81234.00, 'lhodd')
rollback transaction;
-- 1 row affected

-- How about for a non-department head?
execute as user = 'jellis';  -- Customer service employee
begin transaction;
delete dbo.Employee where LoginName = 'jellis';
revert;
select * from dbo.Employee where LoginName = 'jellis';
rollback transaction;
-- 1 row affected

execute as user = 'jellis';  -- Customer service employee
begin transaction;
update dbo.Employee set DepartmentCode = 'IT' where LoginName = 'jellis';
revert;
select * from dbo.Employee where LoginName = 'jellis';
rollback transaction;
-- 1 row affected

execute as user = 'jellis';  -- Customer service employee
begin transaction;
update dbo.Employee set DepartmentCode = 'CS' where LoginName = 'eadkins'; -- Marketing employee
revert;
select * from dbo.Employee where LoginName = 'eadkins';
rollback transaction;
-- 0 rows affected

execute as user = 'jellis';  -- Customer service employee
begin transaction;
insert dbo.Employee (FirstName, LastName, DepartmentCode, Salary, LoginName)
	values ( N'Leonel', N'Hodd', 'IT', 81234.00, 'lhodd')
revert;
select * from dbo.Employee where LoginName = 'lhodd';
rollback transaction;
-- 1 row affected

