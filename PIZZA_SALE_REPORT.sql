use pizzahut


Select * from [dbo].[pizzas]

Select * from order_details
Select * from orders
Select * from pizza_types

--Retrieve the total number of orders placed.
Select count(order_id) as order_count from orders

--Calculate the total revenue generated from pizza sales.
Select round(
             sum(od.quantity*pz.price),2) as total_revenue 
			                                  from order_details as od
                                                             left join pizzas  as pz
                                                                                on od.pizza_id=pz.pizza_id

--Identify the highest-priced pizza.

Select top 1
       pt.name,pz.price 
	      from pizza_types as pt
              left join pizzas as pz
                 on pt.pizza_type_id=pz.pizza_type_id
                    order by pz.price desc 

--Identify the most common pizza size ordered.
   Select pz.size,
             count(od.order_details_id) as order_count 
			        from  order_details as od
                      left join   pizzas as  pz
                         on od.pizza_id=pz.pizza_id
                              group by pz.size
                                   order by count(order_details_id) desc

--List the top 5 most ordered pizza types along with their quantities.

Select top 5 
         pt.name, 
		   sum(od.quantity) as quantity 
		      from pizza_types pt
                left join pizzas pz
                  on pt.pizza_type_id=pz.pizza_type_id
left join order_details od
   on od.pizza_id=pz.pizza_id
      group by pt.name
        order by sum(od.quantity) desc


7.  Join the necessary tables to find the total quantity of each pizza category .
  
  Select pt.category,
              Sum(od.quantity) as quantity
                  from pizza_types as pt
  left join pizzas as pz
                 on pt.pizza_type_id=pz.pizza_type_id
  left join order_details as od
                on  od.pizza_id=pz.pizza_id
  group by pt.category
  order by sum(od.quantity) desc


  --11.     Determine the distribution of orders by hour of the day.

  Select DATEPART(hour,time), 
             count(order_id) as order_count
			           from orders
                    group by daTEPART(hour,time)
                 ORDER BY count(order_id) DESC

				
 --12.    Join relevant tables to find the category-wise distribution of pizzas.

 Select category ,count(name) as count_name from pizza_types
 group by category

 --Group the orders by date and calculate the average number of pizzas ordered per day.

 select  avg(quantity)as avg_quantity   from 
                                (Select o.date , 
							          sum(od.quantity) as quantity from orders as o
                                               join order_details as od
                                                       on o.order_id=od.order_id
                                                              group by o.date

                                                                   )t


----Determine the top 3 most ordered pizza types based on revenue.

Select top 3 pt.name,
      sum(od.quantity*pz.price) as revenue
	   from pizza_types pt
	   join pizzas as pz
	   on pt.pizza_type_id=pz.pizza_type_id
	   join order_details as od
	   on pz.pizza_id=od.pizza_id
	   group by pt.name
	   order by revenue desc

	   --Calculate the percentage contribution of each pizza type to total revenue.

	   
Select  pt.category,
      round(sum(od.quantity*pz.price)/ (Select sum(od.quantity*pz.price) as total_seles from order_details od
	  join pizzas pz on pz.pizza_id=od.pizza_id)*100,2) as revenue
	   from pizza_types pt
	   join pizzas as pz
	   on pt.pizza_type_id=pz.pizza_type_id
	   join order_details as od
	   on pz.pizza_id=od.pizza_id
	   group by pt.category
	   order by revenue desc

	   --Analyze the cumulative revenue generated over time.
	  Select date,sum(revenue)over(order by date ) as cum_revenue from 
	  
	  ( Select o.date,
	   Sum(od.quantity*pz.price) as revenue 
	   from order_details od
	   join pizzas pz
	   on od.pizza_id=pz.pizza_id
	   join orders o
	   on o.order_id=od.order_id
	   group by o.date) as sales

	   --Determine the top 3 most ordered pizza types based on revenue for each pizza category.

	   Select name,revenue from 
	   (select category,name,revenue, rank()over(partition by category order by revenue) rn from
	   
	   (Select pt.category,pt.name,
	   sum((od.quantity)*pz.price) as revenue
	   from pizza_types pt
	   join pizzas pz
	    on pt.pizza_type_id=pz.pizza_type_id
		join order_details od
		on od.pizza_id=pz.pizza_id
		group by pt.category,pt.name)t)t2
		where rn<=3

