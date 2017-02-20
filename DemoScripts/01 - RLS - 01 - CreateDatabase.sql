use master;
go
exec sys.sp_configure 'contained database authentication', 1;
reconfigure;
go
create database CompanyHR containment = partial;
go
use CompanyHR;
go
create table Department
(
	DepartmentCode varchar(5) primary key clustered,
	Description nvarchar(50),
	LeaderEmployeeID int null
);

-- drop table Employee
create table Employee
(
	EmployeeID int not null identity(1,1) primary key clustered,
	FirstName nvarchar(40),
	LastName nvarchar(40),
	DepartmentCode varchar(5),
	Salary money,
	constraint fk_Employee_DepartmentCode foreign key (DepartmentCode) references dbo.Department (DepartmentCode)
);
go
insert dbo.Department (DepartmentCode, Description)
values ('EXEC', 'Executive'), ('MRKT', 'Marketing'), ('IT', 'Information Technology'), ('CS', 'Customer Service'), ('HR', 'Human Resources'), ('PROD', 'Production');

insert dbo.Employee (FirstName, LastName, DepartmentCode, Salary)
values
( N'Joshua', N'Ellis', 'CS', 19299.00 ), 
( N'Goldie', N'Russell', 'MRKT', 61496.00 ), 
( N'Wonda', N'Nelson', 'PROD', 32637.00 ), 
( N'Lois', N'Stapleton', 'EXEC', 202378.00 ), 
( N'Wayne', N'Delorey', 'PROD', 35469.00 ), 
( N'Jennifer', N'Whitlock', 'PROD', 29925.00 ), 
( N'Jared', N'Halligan', 'CS', 32258.00 ), 
( N'Richard', N'Alcantara', 'PROD', 28749.00 ), 
( N'Lynn', N'McGowan', 'PROD', 37975.00 ), 
( N'Harold', N'Mays', 'CS', 27980.00 ), 
( N'Ruth', N'Ritenour', 'IT', 142894.00 ), 
( N'Rhonda', N'Snyder', 'IT', 76009.00 ), 
( N'Michael', N'Glennon', 'HR', 68264.00 ), 
( N'Joel', N'Monahan', 'PROD', 27920.00 ), 
( N'David', N'Shockey', 'CS', 28256.00 ), 
( N'Rosetta', N'Grayson', 'CS', 32920.00 ), 
( N'Crystal', N'Swett', 'IT', 131960.00 ), 
( N'Rita', N'McNeill', 'CS', 27480.00 ), 
( N'Thomas', N'Nichols', 'HR', 66379.00 ), 
( N'Christopher', N'Cann', 'PROD', 22389.00 ), 
( N'Karin', N'Igtanloc', 'CS', 31485.00 ), 
( N'Reed', N'Mercadante', 'MRKT', 45141.00 ), 
( N'Alice', N'Crane', 'PROD', 32312.00 ), 
( N'Bettie', N'Chan', 'PROD', 34197.00 ), 
( N'Edward', N'Middleton', 'PROD', 44930.00 ), 
( N'Gaye', N'Ellis', 'IT', 82079.00 ), 
( N'Summer', N'Jean', 'HR', 51052.00 ), 
( N'Kim', N'Silvey', 'CS', 21733.00 ), 
( N'Evelyn', N'Williams', 'PROD', 19394.00 ), 
( N'Mary', N'Fred', 'IT', 80185.00 ), 
( N'Robert', N'Hamm', 'PROD', 20426.00 ), 
( N'James', N'Saldana', 'CS', 29915.00 ), 
( N'Christel', N'Messer', 'CS', 26657.00 ), 
( N'Alan', N'Pate', 'PROD', 21460.00 ), 
( N'Judy', N'McBride', 'PROD', 27735.00 ), 
( N'Troy', N'Lock', 'PROD', 37012.00 ), 
( N'Patrick', N'Alvara', 'PROD', 26262.00 ), 
( N'John', N'Brackins', 'MRKT', 60435.00 ), 
( N'Ella', N'Adkins', 'MRKT', 53534.00 ), 
( N'Ted', N'Kidd', 'IT', 114186.00 ), 
( N'Christian', N'Segura', 'MRKT', 57297.00 ), 
( N'Ann', N'Jensen', 'MRKT', 54393.00 ), 
( N'Bradley', N'Cabanilla', 'EXEC', 256895.00 ), 
( N'David', N'Oneill', 'PROD', 41699.00 ), 
( N'Susan', N'Scott', 'PROD', 24870.00 ), 
( N'Alicia', N'Kilgo', 'CS', 31107.00 ), 
( N'Richard', N'Devore', 'CS', 25237.00 ), 
( N'Cynthia', N'Floyd', 'IT', 90731.00 ), 
( N'Cheryl', N'Boatner', 'PROD', 37223.00 ), 
( N'Thomas', N'Atkins', 'PROD', 34684.00 );

with EmployeesByDepartmentBySalary as
(
	select e.EmployeeID, e.DepartmentCode,
		row_number() over (partition by e.DepartmentCode order by e.Salary desc) rn
	from dbo.Employee e
)
update d
set d.LeaderEmployeeID = eds.EmployeeID
from dbo.Department d
inner join EmployeesByDepartmentBySalary eds on eds.DepartmentCode = d.DepartmentCode
where eds.rn = 1;

go

alter table dbo.Department alter column LeaderEmployeeID int not null;
alter table dbo.Department add constraint fk_Department_LeaderEmployeeID foreign key (LeaderEmployeeID) references dbo.Employee (EmployeeID);

go

create user EXECuser with password = 'EXECpassword1';
create user MRKTuser with password = 'MRKTpassword1';
create user ITuser with password = 'ITpassword1';
create user CSuser with password = 'CSpassword1';
create user HRuser with password = 'HRpassword1';
create user PRODuser with password = 'PRODpassword1';

--exec CorpDB.dbo.spGenerateRandomCustomers @customersToGenerate = 50;

--insert Employee (FirstName, LastName)
--select top 50 FirstName, LastName from CorpDB.dbo.Customer order by CustomerID desc;

--select * from Employee;


--with EligibleEmployees as
--(
--	select *,
--		row_number() over (order by EmployeeID) rn
--	from dbo.Employee
--	where DepartmentCode is null
--), RandomValue as
--(
--	select top 1 cast(1 + (binary_checksum(newid()) + 2147483648.) / 4294967296. * (select count(*) from EligibleEmployees) as int) RValue
--	from EligibleEmployees
--)
--update ee
--set ee.DepartmentCode = 'PROD'
--from EligibleEmployees ee
--inner join RandomValue rv on rv.RValue = ee.rn
--where 1 = 1;

---- drop table #SalaryRange
--create table #SalaryRange
--(
--	DepartmentCode varchar(5),
--	MinSalary money,
--	MaxSalary money
--);

--insert #SalaryRange (DepartmentCode, MinSalary, MaxSalary)
--values
--('CS', 18000, 35000),
--('EXEC', 180000, 275000),
--('HR', 50000, 70000),
--('IT', 75000, 150000),
--('MRKT', 45000, 65000),
--('PROD', 18000, 45000);

--with Salaries as
--(
--	select e.*,
--		cast(cast(((binary_checksum(newid()) + 2147483648.) / 4294967296.) * (sr.MaxSalary - sr.MinSalary) + sr.MinSalary as int) as money) NewSalary
--	from dbo.Employee e
--	inner join #SalaryRange sr on e.DepartmentCode = sr.DepartmentCode
--)
--update Salaries
--set Salaries.Salary = Salaries.NewSalary;
