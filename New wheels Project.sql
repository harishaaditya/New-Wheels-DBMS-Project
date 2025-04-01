/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/

select state,count(distinct customer_id)no_of_customers_by_state 
from customer_t 
group by state;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/

with temp as(select quarter_number,customer_feedback,case
when customer_feedback='Very bad' then 1
when customer_feedback='bad' then 2
when customer_feedback='okay' then 3
when customer_feedback='good' then 4
when customer_feedback='very good' then 5
end cust_rating from order_t)
select quarter_number,avg(cust_rating) from temp 
group by quarter_number order by quarter_number ;




-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
      -- calculating the percentage of ratings for each quarter 

with temp as(select quarter_number,customer_feedback,case
when customer_feedback='Very bad' then 1
when customer_feedback='bad' then 2
when customer_feedback='okay' then 3
when customer_feedback='good' then 4
when customer_feedback='very good' then 5
end cust_rating,count(customer_feedback)no_of_cust,
sum(count(customer_feedback)) over(partition by quarter_number)total_cust_by_quarter
from order_t group by quarter_number,customer_feedback)
select quarter_number,cust_rating,no_of_cust,total_cust_by_quarter,
(no_of_cust/total_cust_by_quarter)*100 percentage_of_cust_by_category_for_each_quarter 
from temp order by quarter_number,cust_rating;
-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

select vehicle_maker,count(customer_id) from product_t p join order_t o on p.product_id=o.product_id 
group by vehicle_maker order by count(customer_id)desc;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

with temp as (select state,vehicle_maker,count(o.customer_id)cnt,
rank() over(partition by state order by count(customer_id) desc)rnk 
from product_t  p join order_t o on p.product_id=o.product_id 
join customer_t c on o.customer_id=c.customer_id 
group by state,vehicle_maker order by state,count(o.customer_id) desc)
select state,vehicle_maker,cnt from temp where rnk=1;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

select quarter_number,count(order_id) from order_t 
group by quarter_number order by quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
      
      with temp as(select quarter_number,sum(vehicle_price)rev_by_quarter 
      from order_t group by quarter_number order by quarter_number)
      select quarter_number,rev_by_quarter,lag(rev_by_quarter) over(),(rev_by_quarter-lag(rev_by_quarter) over())/rev_by_quarter 
      from temp;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

select quarter_number,sum(vehicle_price),count(customer_id) from order_t 
group by quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

select credit_card_type,avg(discount) from order_t o 
join customer_t c on o.customer_id=c.customer_id group by credit_card_type;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

select quarter_number,avg(datediff(ship_date,order_date))avg_time_taken_in_days 
from order_t group by quarter_number;


-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



