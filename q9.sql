-- if each $1 spent equates to 10 points and sushi 
-- has a 2x points multiplier - how many points 
-- would each customer have?
with cte as
( select m.product_id, 
case  when m.product_id = 1 then m.price*20
       else m.price*10
	   end as points
	from menu m)
select s.customer_id ,sum(c.points) as total_points
from sales s
join cte c on c.product_id= s.product_id
group by s.customer_id;