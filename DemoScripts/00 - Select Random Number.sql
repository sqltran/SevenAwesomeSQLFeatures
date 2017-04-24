select top 1 n.n
from Admin.dbo.Nums n
where n.n >= 1
and n.n <= 100
order by newid();
