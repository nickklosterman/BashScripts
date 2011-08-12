"create table Backcountrydeals (Bkey INTEGER PRIMARY KEY, websiteCode int, product TEXT, price double, percentOffMSRP int, quantity int, dealduration\
inminutes int, timeEnter DATE);"
    sqlite3 test.db "create table WebsiteCodes (WKey INTEGER PRIMARY KEY, website TEXT, websiteCode int);"
    sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('Steep and Cheap', 0);"
    sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('WhiskeyMilitia', 1);"
    sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('Bonktown', 2);"
    sqlite3 test.db "insert into WebsiteCodes (website, websiteCode) values ('Chainlove', 3);"

create table ProductImages( image_id serial, filename varchar(255) not null, number_of_times_seen int not null default 1, last_seen timestamp default current_timestamp on update current_timestamp,  primary key (image_id), index (filename));

#I set the product varchar() at 120 cuz I did a dump of the sqlite dbase and did a wc -L and got 77 as the return value, added some buffer, hopefully saved some space --sqlite3  test.db "select product from Backcountrydeals" | wc -L

#How much savings would I get if I made the price an int and simply moved the decimal whenever entering or displaying that data column? Well I imagine I coudl do that later inan update or alter call if need be.
create table Backcountrydeals (Bkey serial, websiteCode int not null, product varchar(120), price float, percentOffMSRP int not null, quantity int not null, dealdurationinminutes int, timeEnter datetime default null, primary key (Bkey), index (product));
CREATE TRIGGER product_entered_at BEFORE INSERT ON Backcountrydeals FOR EACH ROW SET NEW.timeEnter = UTC_TIMESTAMP;

#is it going to be a headache converting from utc_time to local time?
#http://dev.mysql.com/doc/refman/5.0/en/date-and-time-functions.html#function_convert-tz

create table WebsiteCodes (Wkey serial, website varchar(25), websiteCode int, primary key (Wkey));
insert into WebsiteCodes (website, websiteCode) values ('Steep and Cheap', 0);
insert into WebsiteCodes (website, websiteCode) values ('WhiskeyMilitia', 1);
insert into WebsiteCodes (website, websiteCode) values ('Bonktown', 2);
insert into WebsiteCodes (website, websiteCode) values ('Chainlove', 3);

------------------------------------
create table BackcountryProducts (ProductEntrykey serial, websiteCode int not null, product varchar(120), primary key (ProductEntrykey), index (product));
create table BackcountryProductDetails (DetailEntrykey serial, ProductEntrykey int not null, price float, percentOffMSRP int not null, quantity int not null, dealdurationinminutes int, timeEnter datetime default null, primary key (DetailEntrykey), index (ProductEntrykey));
CREATE TRIGGER product_entered_at2 BEFORE INSERT ON BackcountryProductDetails FOR EACH ROW SET NEW.timeEnter = UTC_TIMESTAMP;
#I had to rename the trigger as "product_entered_at" had all ready been created, so I just addded a 2 to the end to make it "product_entered_at2" and then mysql accepted the query


#actually we run in to problems when the price is set as a float and we try to select based on that.  So we need to set it as a decimal
create table BackcountryProductDetails (DetailEntrykey serial, ProductEntrykey int not null, price decimal(6,2), percentOffMSRP int not null, quantity int not null, dealdurationinminutes int, timeEnter datetime default null, primary key (DetailEntrykey), index (ProductEntrykey));


#or why even bother with decimal since most of the prices will be XX.99 and really should just be solid numbers instead.
create table BackcountryProductDetails (DetailEntrykey serial, ProductEntrykey int not null, price int, percentOffMSRP int not null, quantity int not null, dealdurationinminutes int, timeEnter datetime default null, primary key (DetailEntrykey), index (ProductEntrykey));
#but will I need to round to enter the price in or will mySQL take care of that (and do it the way I want??) best to round before entry

In the end I just altered the table and now performing queries liek "....where price=1.99" work
ALTER TABLE BackcountryProductDetails CHANGE price price DECIMAL (6,2);