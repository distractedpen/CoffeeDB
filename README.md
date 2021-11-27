CoffeeDB Project for CS617 DB, Data Mining, and Big Data

Class Project in cleaning and storing data for a fake chain of coffee shops. Extensive use of triggers and reorganization of data into the following schema:

ShopId(sid integer primary key, name string)
CustomerId(cid integer primary key, name string, year integer, month integer, day integer)
Revenue(sid integer primary key references ShopId(sid), visits integer default 0, revenue real default 0, avgAge integer default 0)
Expenditures(cid integer primary key references CustomerId(cid), visits integer default 0, expenditures real default 0)
Transactions(cid integer not null references CustomerId(cid), sid integer not null references ShopId(sid), coffee string, price real default 0)

Run the following command to create a new database file (Requires sqlite3 to be installed):
```
  sqlite3 coffee.db < coffeeDB.sql
```
The small.csv, medium.csv, and large.csv files are example data for use of testing the schema of this database. Open the database file in sqlite3 and use
```
  .import small.csv RawImportData
```
to see the database in action. Delete the database file and rerun the command line command above to test out medium.csv and large.csv.
