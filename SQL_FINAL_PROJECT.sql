create database pizzahut;
use pizzahut;
select * from pizzas;
select * from order_details;
select * from pizza_types;
select * from orders;


/*retrieve the total number of orders placed*/


        select count(order_id) 
           as total_orders 
        from orders;


/*calculate the total revenue generated from pizza sales*/


         select round(sum(pizzas.price*order_details.quantity),2) 
           as Total_revenue from pizzas
             join order_details on
         pizzas.pizza_id = order_details.pizza_id;



/*Identify the highest-priced pizza.*/
/*select max(price) from pizzas;*/
/*select pizza_id,price from pizzas where
price in (select max(price) from pizzas);*/


select pizza_types.name,pizzas.price from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
where pizzas.price in (select max(price) from pizzas);


/*second method*/

          select top 1 pizza_types.name,pizzas.price from pizza_types
             join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
           order by pizzas.price desc;





/*Identify the most common pizza size ordered.*/

/*select quantity,count(pizza_id) from order_details group by quantity;*/

           select top 1 pizzas.size,
             count(order_details.order_details_id) from pizzas
           join order_details on pizzas.pizza_id=order_details.pizza_id 
		    group by pizzas.size 
            order by count(order_details.order_details_id) desc;






/*List the top 5 most ordered pizza types along with their quantities.*/

select top 5 pizza_types.name,sum(order_details.quantity) from pizzas
join order_details on pizzas.pizza_id=order_details.pizza_id
join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by pizza_types.name
order by sum(order_details.quantity) desc;






/*Join the necessary tables to find the total
quantity of each pizza category ordered.*/
select pizza_types.category,sum(order_details.quantity)
as Total_Quantity from pizzas
join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
inner join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category order by sum(order_details.quantity) desc;


/*Determine the distribution of orders by hour of the day.*/
select DATEPART(hour,time) as Time_hour,count(order_id) as Total_order from orders
group by DATEPART(hour,time)
order by DATEPART(hour,time) ;




/*Join relevant tables to find the category-wise distribution of pizzas.*/
select category,count(name) as total_varient from pizza_types
group by category;


/*Group the orders by date and calculate the
average number of pizzas ordered per day.*/
SELECT AVG(DailyOrders.Total_order) AS Avg_Order_Per_Day
FROM (
    SELECT orders.date, SUM(order_details.quantity) AS Total_order
    FROM orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date
) AS DailyOrders;




/*Determine the top 3 most ordered pizza types based on revenue.*/
select top 3 pizza_types.name,sum(pizzas.price*order_details.quantity) as revenue 
from pizzas join order_details on pizzas.pizza_id=order_details.pizza_id
join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by pizza_types.name order by revenue desc;


/*Calculate the percentage contribution of each pizza type to total revenue.*/
select pizza_types.category,

round(((sum(pizzas.price*order_details.quantity))/
(select round(sum(pizzas.price*order_details.quantity),2) 
as Total_revenue from pizzas
join order_details on
pizzas.pizza_id = order_details.pizza_id
) )*100,2) as percentage_contribution_of_each_pizza

from pizzas join order_details on pizzas.pizza_id=order_details.pizza_id
join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by pizza_types.category;


/*Analyze the cumulative revenue generated over time.*/ 
select date,sum(revenue)over(order by date) as cum_revenue from

(select orders.date,sum(pizzas.price*order_details.quantity) as revenue
from pizzas join order_details
on pizzas.pizza_id=order_details.pizza_id
join orders on orders.order_id=order_details.order_id
group by orders.date) as sales;




/*Determine the top 3 most ordered pizza types
based on revenue for each pizza category.*/
/*Using CTE*/

WITH RankedPizzas AS (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        SUM(pizzas.price * order_details.quantity) AS revenue,
        RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(pizzas.price * order_details.quantity) DESC) AS rn
    FROM pizza_types
    JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
)

SELECT category, name, revenue, rn
FROM RankedPizzas
WHERE rn <= 3;


/*
select * from pizzas;
select * from order_details;
select * from pizza_types;
select * from orders
select * from order_details;
*/





