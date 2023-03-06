-- Part 1 – Sales and Delivery:

use miniproject_sales;
select * from prod_dimen;
select * from shipping_dimen;

-- Question 1: Find the top 3 customers who have the maximum number of orders
select * from cust_dimen;
select * from orders_dimen;
select * from market_fact; 


select customer_name,cust_id,count(distinct ord_id) as count_of_orders from market_fact join cust_dimen 
using(cust_id)
group by cust_id
order by count_of_orders desc
limit 3;




select * from 
(select cd.Cust_id, cd.customer_name,count(mf.ord_id) ,dense_rank()over( order by count(mf.ord_id) desc)  as maximum_order from
cust_dimen cd join market_fact mf 
on cd.cust_id = mf.Cust_id
group by Cust_id  )t
where maximum_order <=3;

-- Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.


select *, datediff(shipp_date,orderr_date)DaysTakenForDelivery from 
(select *,str_to_date(order_date,'%d-%m-%Y')orderr_date,str_to_date(ship_date,'%d-%m-%Y')shipp_date
from orders_dimen join shipping_dimen
using(order_id))t
order by DaysTakenForDelivery desc;

select * ,datediff((str_to_date(ship_date,"%d-%m-%Y")),(str_to_date(order_date,"%d-%m-%Y"))) as daystakenfordelivery
from orders_dimen join shipping_dimen
using(order_id);

-- Question 3: Find the customer whose order took the maximum time to get delivered.

with customer as (
select Cust_id,datediff(str_to_date(ship_date,'%d-%m-%Y'),str_to_date(order_date,'%d-%m-%Y'))DaysTakenForDelivery
 from orders_dimen join shipping_dimen
using(order_id)
join market_fact
using(ord_id)
order by DaysTakenForDelivery desc
limit 1)
select customer_name ,DaysTakenForDelivery from customer c, cust_dimen cd  where c.Cust_id =  cd.Cust_id;

-- dean percer from yunkonis the customer who received the  order which took maximum days to deliver


-- Question 4: Retrieve total sales made by each product from the data (use Windows function)
select distinct Product_sub_Category,sum(sales)over(partition by Product_sub_category) as total_sale 
from market_fact mf join prod_dimen pd using(prod_id);



select distinct prod_id,round(sum(sales)over(partition by prod_id),2) as total_sales
from market_fact;

-- Question 5: Retrieve the total profit made from each product from the data (use windows function)

select distinct Product_sub_Category,sum(profit)over(partition by product_sub_category) as total_profit 
from market_fact mf join prod_dimen pd 
using(prod_id);


select distinct prod_id,round(sum(profit)over(partition by prod_id),2) as total_profit
from market_fact;

-- Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

select year(orderrdate)year_of_orderdate,month(orderrdate)month_of_orderdate,count(distinct(cust_id))unique_customer from
(select *, str_to_date(order_date,'%d-%m-%Y') as orderrdate 
from orders_dimen join market_fact
using(ord_id))t
where year(orderrdate) = 2011
and month(orderrdate)=1;

-- total no of unique customer in january 2011 is 99.



-- Part 2 – Restaurant:
use miniproject;


-- Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.

select * from geoplaces2;
select * from rating_final;

select count(userId) from rating_final
where placeID in
(select distinct placeid from geoplaces2
where alcohol != 'No_Alcohol_Served');


select distinct placeid,name,alcohol,count(placeid)over(partition by placeid ) from rating_final r join geoplaces2 g
using(placeid)
order  by alcohol;

-- Question 2: -Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.

select  alcohol,price,avg(rating),avg(food_rating),avg(service_rating) from
(select placeid,price,alcohol,rating,food_rating,service_rating from geoplaces2 join 
rating_final 
using(placeid))t
group by alcohol,PRICE
order by alcohol;

select alcohol,price,avg(rating) from rating_final join geoplaces2
using(placeid)
group by alcohol,price
order by alcohol,price;

-- Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol categories along with the total number of restaurants.

select alcohol,parking_lot,count(placeId)no_of_restaurents from
(select placeid,parking_lot,alcohol from chefmozparking
join geoplaces2
using(placeid))t
group by parking_lot,alcohol
order by alcohol,parking_lot;



-- Question 4: -Also take out the percentage of different cuisine in each alcohol type.


select alcohol,different_cuisine,total_cuisine,round(different_cuisine *100/total_cuisine,2)percentage from
(select alcohol,count(Rcuisine)different_cuisine,
sum(count(Rcuisine))over() total_cuisine from
(select placeid,rcuisine,alcohol from chefmozcuisine
join geoplaces2
using(placeid))t
group by alcohol)tt;


-- Questions 5: - let’s take out the average rating of each state.

select state, avg(rating) avg_rating from
(select placeid,rating,state from geoplaces2 join 
rating_final 
using(placeid))t
group by state
order by avg_rating desc;

-- Questions 6: -' Tamaulipas' Is the lowest average rated state. Quantify the reason why it is the lowest rated by providing the summary on the
-- basis of State, alcohol, and Cuisine.

(select placeid,price,alcohol,rating,rcuisine,state from geoplaces2 join 
rating_final 
using(placeid)
left join chefmozcuisine
using(placeid)
where state ='Tamaulipas');

(select placeid,price,alcohol,rating,rcuisine,state from geoplaces2 join 
rating_final 
using(placeid)
 join chefmozcuisine
using(placeid)
where state ='san luis potos');

(select placeid,price,alcohol,rating,rcuisine,state from geoplaces2 join 
rating_final 
using(placeid)
 join chefmozcuisine
using(placeid)
where state ='Morelos');


-- Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or 
-- Italian types of cuisine, and also their budget level is low.
-- We encourage you to give it a try by not using joins.


select * from Chefmozcuisine;
select * from geoplaces2;
select * from rating_final;

select  placeid,price,alcohol,rating,food_rating,service_rating,state ,name,rcuisine
from geoplaces2 join  rating_final 
using(placeid)
join Chefmozcuisine
using(placeid)
where rcuisine='mexican' or rcuisine='italian' and price='low';





-- Question 1:
-- Create two called Student_details and Student_details_backup.

-- Let’s say you are studying SQL for two weeks. In your institute, there is an employee who has been maintaining the student’s details and Student Details Backup tables.
-- He / She is deleting the records from the Student details after the students completed the course and keeping the backup in the student details
--  backup table by inserting the records every time. You are noticing this daily and now you want to help him/her by not inserting the records for backup purpose 
-- when he/she delete the records.write a trigger that should be capable enough to insert the student details in the backup table whenever the employee deletes 
-- records from the student details table.

-- Note: Your query should insert the rows in the backup table before deleting the records from student details.



--- trigger

create table Student_details
(
Student_id int,
Student_name varchar(20),
Mail_ID varchar(20),
Mobile_NO int
);
create table Student_details_backup
(
Student_id int,
Student_name varchar(20),
Mail_ID varchar(20),
Mobile_NO int
);
create trigger backups
before insert
on student_details
for each row
insert into Student_details_backup(Student_id,Student_name,Mail_ID,Mobile_NO) values 
(new.Student_id,new.Student_name,new.Mail_ID,new.Mobile_NO);