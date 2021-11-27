pragma foreign_keys=1;

-- create Tables
create table ShopId(sid integer primary key, name string);
create table CustomerId(cid integer primary key, name string, year integer, month integer, day integer);
create table Revenue(sid integer primary key references ShopId(sid), visits integer default 0, revenue real default 0, avgAge integer default 0);
create table Expenditures(cid integer primary key references CustomerId(cid), visits integer default 0, expenditures real default 0);
create table Transactions(cid integer not null references CustomerId(cid), sid integer not null references ShopId(sid), coffee string, price real default 0);
create table RawImportData(cid string, sid string, coffee string, price string);


-- Triggers
create trigger updateRevrev after insert on Transactions
	begin update Revenue
		set
			revenue = revenue + new.price,
			visits = visits + 1,
			avgAge = ( (avgAge*visits + (select case when month < 10 or (month = 10 and day < 31) then 2021-year else 2021-year-1 end from CustomerID where cid = new.cid)) / (visits + 1) )
		where sid = new.sid;
	end;

create trigger updateExpvis after insert on Transactions
	begin update Expenditures
		set
			visits = visits + 1,
			expenditures = expenditures + new.price
		where cid = new.cid;
	end;

create trigger deleteRevrev before delete on Transactions
	begin update Revenue
		set
			revenue = revenue - old.price,
			visits = visits - 1,
			avgAge = ( (avgAge*visits - (select case when month < 10 or (month = 10 and day < 31) then 2021-year else 2021-year-1 end from CustomerID where cid = old.cid)) / (visits - 1) )
		where sid = old.sid;
	end;

create trigger deleteExpvis before delete on Transactions
	begin update Expenditures
		set
			visits = visits - 1,
			expenditures = expenditures - old.price
		where cid = old.cid;
	end;

-- trigger to check transaction contains correct data before insertion
create trigger insertTransaction after insert on RawImportData
	when ((new.cid not null and new.cid in (select cid from CustomerID)) and
		 (new.sid not null and new.sid in (select sid from ShopId)) and
		  new.coffee not null and new.price not null)
	begins
		insert into Transactions values (new.cid, new.sid, new.coffee, new.price);
		delete from RawImportData where cid=new.cid and sid=new.sid and coffee=new.coffee and price=new.price;
	end;

-- Populate CustomerId table
create temp table People(name string, age integer, birthday string);
.separator ':'
.import People.txt People
create temp table idNumber(id integer, name string);
insert into idNumber select (rowid+1000), name from People;
create temp table month(mon string);
insert into month values ("jan"), ("feb"), ("mar"), ("apr"), ("may"), ("jun"), ("jul"), ("aug"), ("sep"), ("oct"), ("nov"), ("dec");

insert into CustomerId(cid, name, month, day)
	select idnumber.id, idnumber.name, month.rowid, substr(people.birthday,5,2)
	from idNumber natural join people left join month on substr(people.birthday,1,3)=mon;
-- create view to determine if birthday passed
create temp view BdayPassed as
	select cid, (month < 10 or (month = 10 and day < 31)) as passed, date("now")-age-1 as before, date("now")-age as after
	from CustomerId natural join temp.idNumber natural join People;
-- insert correct year into CustomerId based on BdayPassed.passed
update CustomerId set year=(select case when passed then after else before end from temp.BdayPassed where customerId.cid=temp.BdayPassed.cid);

-- Populate Expenditures Table
insert into Expenditures(cid) select cid from CustomerID;

-- Populate ShopId table
.separator ','
.import Shops.txt ShopId

-- Populate Revenue table
insert into Revenue(sid) select sid from ShopId;
