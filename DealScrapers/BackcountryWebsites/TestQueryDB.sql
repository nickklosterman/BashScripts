create table TestProduct (key1 serial, product varchar(120), primary key(key1), index(product)); 
create table TestProductDetails (key2 serial, foreignkey int not null, storename varchar(120), price decimal(8,2), primary key(key2), index(foreignkey));

insert into TestProduct (product) values (''); 
insert into TestProduct (product) values (''); 
insert into TestProduct (product) values (''); 

insert into TestProductDetails (foreignkey, storename, price) values ( , '' , );
insert into TestProductDetails (foreignkey, storename, price) values ( , '' , );
insert into TestProductDetails (foreignkey, storename, price) values ( , '' , );
insert into TestProductDetails (foreignkey, storename, price) values ( , '' , );
insert into TestProductDetails (foreignkey, storename, price) values ( , '' , );
insert into TestProductDetails (foreignkey, storename, price) values ( , '' , );
insert into TestProductDetails (foreignkey, storename, price) values ( , '' , );
insert into TestProductDetails (foreignkey, storename, price) values ( , '' , );

insert into TestProduct (product) values ('milk'); 
insert into TestProduct (product) values ('bread'); 
insert into TestProduct (product) values ('cheese'); 

insert into TestProductDetails (foreignkey, storename, price) values (1 , 'Grocery' ,2.89 );
insert into TestProductDetails (foreignkey, storename, price) values (1 , 'Convenience' ,1.99 );
insert into TestProductDetails (foreignkey, storename, price) values (1 , 'Grocery' ,1.99 );
insert into TestProductDetails (foreignkey, storename, price) values (1 , 'Grocery' ,1.99 );
insert into TestProductDetails (foreignkey, storename, price) values (2 , 'Grocery' , 3.49 );
insert into TestProductDetails (foreignkey, storename, price) values (2 , 'Convenience' , 2.99 );
insert into TestProductDetails (foreignkey, storename, price) values (2 , 'Convenience' , 2.99 );
insert into TestProductDetails (foreignkey, storename, price) values (3 , 'Grocery' , 8.99);
insert into TestProductDetails (foreignkey, storename, price) values (3 , 'Grocery' , 7.89);
insert into TestProductDetails (foreignkey, storename, price) values (3 , 'Convenience' , 7.89);
insert into TestProductDetails (foreignkey, storename, price) values (3 , 'Grocery' , 8.99);

mysql> select * from TestProduct;
+------+---------+
| key1 | product |
+------+---------+
|    1 | milk    |
|    2 | bread   |
|    3 | cheese  |
+------+---------+
3 rows in set (0.07 sec)

mysql> select * from TestProductDetails;
+------+------------+-------------+-------+
| key2 | foreignkey | storename   | price |
+------+------------+-------------+-------+
|    1 |          1 | Grocery     |  2.89 |
|    2 |          1 | Convenience |  1.99 |
|    3 |          1 | Grocery     |  1.99 |
|    4 |          1 | Grocery     |  1.99 |
|    5 |          2 | Grocery     |  3.49 |
|    6 |          2 | Convenience |  2.99 |
|    7 |          2 | Convenience |  2.99 |
|    8 |          3 | Grocery     |  8.99 |
|    9 |          3 | Grocery     |  7.89 |
|   10 |          3 | Convenience |  7.89 |
|   11 |          3 | Grocery     |  8.99 |
+------+------------+-------------+-------+
11 rows in set (0.10 sec)

I believe that I have designed/normalized the database appropriately.
 

select p.product,d.storename,d.price from TestProduct p , TestProductDetails d where p.key1=d.foreignkey;
+---------+-------------+-------+
| product | storename   | price |
+---------+-------------+-------+
| milk    | Grocery     |  2.89 |
| milk    | Convenience |  1.99 |
| milk    | Grocery     |  1.99 |
| milk    | Grocery     |  1.99 |
| bread   | Grocery     |  3.49 |
| bread   | Convenience |  2.99 |
| bread   | Convenience |  2.99 |
| cheese  | Grocery     |  8.99 |
| cheese  | Grocery     |  7.89 |
| cheese  | Convenience |  7.89 |
| cheese  | Grocery     |  8.99 |
+---------+-------------+-------+

However I'd like these results:
+---------+-------------+-------+
| product | storename   | price |
+---------+-------------+-------+
| milk    | Grocery     |  2.89 |
| milk    | Convenience |  1.99 |
| milk    | Grocery     |  1.99 |
| bread   | Grocery     |  3.49 |
| bread   | Convenience |  2.99 |
| cheese  | Grocery     |  8.99 |
| cheese  | Grocery     |  7.89 |
| cheese  | Convenience |  7.89 |
+---------+-------------+-------+
I think I'd have to have some sort of cascaded distinct() queries but am not sure how to do it. 

Is there a way to count the number of records with the same foreign key and have the result associated with the product from the first table?I'm looking for results something like this:
product | count (entries) 
milk	| 4
bread	| 3
cheese 	| 4
Along those same lines would it make sense to have a count column in TestProduct (that I'd update every time a record was added) since there is the count() function?


I know I can perform the query piecemeal: select distinct(pp.product),( select count(d.price) from TestProductDetails d, TestProduct p where p.key1=d.foreignkey and p.product="bread")  from TestProduct pp where pp.product="bread"; I'm just wondering if I can get all the results in one go.

select pp.product,( select d.storename from TestProductDetails d, TestProduct p where p.key1=d.foreignkey and p.product="bread"),(select ddd.price from TestProductDetails ddd, TestProduct ppp where ppp.key1=ddd.foreignkey and ppp.product="bread")  from TestProduct pp where pp.product="bread";
ERROR 1242 (21000): Subquery returns more than 1 row