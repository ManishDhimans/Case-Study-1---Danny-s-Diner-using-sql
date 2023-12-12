Q 1 What is the total amount each customer spent at the restaurant?

select s.customer_id,sum(m.price) as total_amount 
from sales s
join menu m on s.product_id=m.product_id
group by s.customer_id;

Q 2 How many days has each customer visited the restaurant?

select customer_id, count(distinct(order_date)) 
as visiting_days 
from sales
group by customer_id
order by visiting_days desc;

Q 3 What was the first item from the menu purchased by each customer?
select distinct(s.customer_id), m.product_name 
from sales s
join menu m on s.product_id=m.product_id
where s.order_date = any
(select min(order_date) from sales
group by customer_id)

Q 4 What is the most purchased item on the menu and how many times was it purchased by all customers? 

select count(m.product_name) as most_purchased, 
product_name 
from sales s
join menu m on s.product_id = m.product_id
group by m.product_name
order by most_purchased desc;

5 Which item was the most popular for each customer?

select count(s.product_id) as count, m.product_name,
s.customer_id
from sales s
join menu m on s.product_id = m.product_id
group by customer_id,product_name
order by count desc;

Q 5 -- 2nd way

with rk as
(SELECT s.customer_id,m.product_name,
        COUNT(s.product_id) as count,
        dense_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS runk
FROM menu m 
JOIN sales s 
ON s.product_id = m.product_id
GROUP BY s.customer_id, s.product_id, m.product_name
)
select customer_id, product_name, count 
from rk where runk =1;

Q 6 Which item was purchased first by the customer after they became a member? 

with cte as
(select s.customer_id,
       m.product_name, s.order_date,
    dense_rank() over (PARTITION BY s.customer_id ORDER BY s.order_date) as ranks
from sales s
join menu m on s.product_id = m.product_id
join members as mb
ON mb.customer_id = s.customer_id
where s.order_date >= mb.join_date)
select customer_id, product_name, order_date,ranks
from cte 
where ranks =1;

Q 7 Which item was purchased just before the customer became a member? 

with cte as
(select s.customer_id,
       m.product_name, s.order_date,mb.join_date,
    dense_rank() over (PARTITION BY s.customer_id ORDER BY s.order_date desc) as ranks
from sales s
join menu m on s.product_id = m.product_id
join members as mb
ON mb.customer_id = s.customer_id
where s.order_date < mb.join_date)
select customer_id, product_name,order_date,ranks,join_date
from cte 
where ranks =1;

Q 8 What is the total items and amount spent for each member before they became a member?

select s.customer_id, count(s.product_id) as total_items, 
sum(m.price) as total_sales
from sales s 
join menu m on s.product_id= m.product_id
join members mb on s.customer_id=mb.customer_id 
where s.order_date < mb.join_date
group by s.customer_id;

Q 9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with cte as
( select m.product_id, 
case  when m.product_id = 1 then m.price*20
       else m.price*10
	   end as points
	from menu m)
select s.customer_id ,sum(c.points) as total_points
from sales s
join cte c on c.product_id= s.product_id