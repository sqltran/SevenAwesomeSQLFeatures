-- 5/6/2017 by Allison Benneth (allison at sqltran dot org)
-- Feel free to use in any way you would like.

drop database if exists PersonDW;
go
create database PersonDW;
go
use PersonDW;
go

drop table if exists PersonDim;
go
create table PersonDim
(
	PersonID int not null,
	FirstName nvarchar(30) not null,
	LastName nvarchar(30) not null,
	AddressLine1 nvarchar(75) not null,
	City nvarchar(40) not null,
	State nvarchar(5) not null,
	constraint pk_PersonDim primary key clustered (PersonId)
);

with FirstNames as
(
	select FirstName
	from (values ('Mary'), ('Jeremiah'), ('Lorena'), ('Robert'), ('Carrie'), 
		('Michael'), ('Wanda'), ('Antoinette'), ('Jarod'), ('Dana')) fn (FirstName)
), LastNames as
(
	select LastName
	from (values ('Schinke'), ('Weber'), ('Barber'), ('Simmons'), ('Sage'), 
		('Cureton'), ('Wardlaw'), ('Hermansen'), ('Novick'), ('Carden')) ln (LastName)
), Streets as
(
	select StreetName
	from (values ('Carew Terr'), ('Morandi St'), ('Huntley Meadows St'), ('Limmings Rd'), ('Sandbed Terr'), 
		('Cerra Vista Ln'), ('Lenwood Ln'), ('Timbercrest Ln'), ('Holme House Rd'), ('Del Camino Rd')) st (StreetName)
), StreetNumberPlaceholders as
(
	select Placeholder
	from (values (1), (1)) snp (Placeholder)
), Cities as
(
	select CityName
	from (values ('Lake Park'), ('Little Valley'), ('Speers'), ('Sykesville'), ('Grand Meadow'), 
		('Energy'), ('Royalton'), ('Pandora'), ('Pine Bluffs'), ('Princeton')) cn (CityName)
), States as
(
	select State
	from (values ('AK'), ('AL'), ('AR'), ('AZ'), ('CA'), ('CO'), ('CT'), ('DE'), ('FL'), ('GA'), 
		('HI'), ('IA'), ('ID'), ('IL'), ('IN'), ('KS'), ('KY'), ('LA'), ('MA'), ('MD'), 
		('ME'), ('MI'), ('MN'), ('MO'), ('MS'), ('MT'), ('NC'), ('ND'), ('NE'), ('NH'), 
		('NJ'), ('NM'), ('NV'), ('NY'), ('OH'), ('OK'), ('OR'), ('PA'), ('RI'), ('SC'), 
		('SD'), ('TN'), ('TX'), ('UT'), ('VA'), ('VT'), ('WA'), ('WI'), ('WV'), ('WY')) st (State)
), Persons as
(
	select
		newid() PersonGuid,
		fn.FirstName,
		ln.LastName,
		cast(cast(100. + (binary_checksum(newid()) + 2147483648.) / 4294967296. * 900. as int) as nvarchar(10)) + ' ' + st.StreetName AddressLine1,
		ci.CityName,
		sta.State
	from FirstNames fn
	cross apply LastNames ln
	cross apply Streets st
	cross apply StreetNumberPlaceholders snp
	cross apply Cities ci
	cross apply States sta
)
insert PersonDim (PersonID, FirstName, LastName, AddressLine1, City, State)
select row_number() over (order by PersonGuid) PersonID, FirstName, LastName, AddressLine1, CityName, State
from Persons;
