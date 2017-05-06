-- 5/6/2017 by Allison Benneth (allison at sqltran dot org)
-- Feel free to use in any way you would like.

use CompanyHR;
go

-- So how can prevent a user from updating a row in such a way
-- that they can no longer access that data?
-- Answer: Block predicates.

-- Without the block predicate, department leader rgrayson can update fellow
-- customer service employee 'jhalligan' to another department.
execute as user = 'rgrayson';  -- Customer service department head
begin transaction;
update dbo.Employee set DepartmentCode = 'IT' where LoginName = 'jhalligan';
select * from dbo.Employee where LoginName = 'jhalligan';
revert;
select * from dbo.Employee where LoginName = 'jhalligan';
rollback transaction;
-- 1 row affected

-- Now add a block predicate.
alter security policy EmployeeFilter
add block predicate Security.fnEmployeeRLSPredicate (LoginName, DepartmentCode)
on dbo.Employee after insert,
add block predicate Security.fnEmployeeRLSPredicate (LoginName, DepartmentCode)
on dbo.Employee after update;

-- Try the same operation.
execute as user = 'rgrayson';  -- Customer service department head
begin transaction;
update dbo.Employee set DepartmentCode = 'IT' where LoginName = 'jhalligan';
select * from dbo.Employee where LoginName = 'jhalligan';
revert;
select * from dbo.Employee where LoginName = 'jhalligan';
rollback transaction;
-- Msg 33504, Level 16, State 1, Line 26
-- The attempted operation failed because the target object 'CompanyHR.dbo.Employee' has a block predicate that conflicts with this operation. If the operation is performed on a view, the block predicate might be enforced on the underlying table. Modify the operation to target only the rows that are allowed by the block predicate.
-- The statement has been terminated.

alter security policy EmployeeFilter
drop block predicate on dbo.Employee after insert;

alter security policy EmployeeFilter
drop block predicate on dbo.Employee after update;
