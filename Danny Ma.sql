DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', 'null', 'null', '2020-01-01 18:05:02'),
  ('2', '101', '1', 'null', 'null', '2020-01-01 19:00:52'),
  ('3', '102', '1', 'null', 'null', '2020-01-02 23:51:23'),
  ('3', '102', '2', 'null', 'null', '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', 'null', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', 'null', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', 'null', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1,5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2,6', '1,4', '2020-01-11 18:34:49');

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', 'null'),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', 'null'),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 minutes', 'null'),
  ('4', '2', '2020-01-04 13:53:03', '23.4km', '40 minutes', 'null'),
  ('5', '3', '2020-01-08 21:10:57', '10km', '15 minutes', 'null'),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25 minutes', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4km', '15 minutes', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10 minutes', 'null');

CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

-- How many pizzas were ordered?
select count(order_id) as TotalOrders
from customer_orders;

-- How many unique customer orders were made?
select count (distinct order_id) as UniqueOrders
from customer_orders;

-- How many orders were successfully delivered by each runner?
select runner_id, count(runner_id) as SuccessfulOrders
from runner_orders
group by runner_id, cancellation
having cancellation = 'null'

-- How many of each type of pizza was delivered?
select t1.pizza_id, count(t1.order_id) as Total_Pizza_No
from customer_orders t1
full join runner_orders t3
on t1.order_id = t3.order_id
group by pizza_id, cancellation
having cancellation = 'null';

-- How many Vegetarian and Meatlovers were ordered by each customer?
select t2.pizza_name, count(t1.order_id) as Total_Pizza_No
from customer_orders t1
full join pizza_names t2
on t1.pizza_id = t2.pizza_id
group by pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
select count(t3.pickup_time) Total_orders
from customer_orders t1
full join runner_orders t3
on t1.order_id = t3.order_id
group by pickup_time, cancellation
having cancellation = 'null'
order by Total_orders desc;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
Select count(t1.order_id) Atleast_1_Change
from customer_orders t1
full join runner_orders t3
on t1.order_id = t3.order_id
where exclusions <> 'null' or extras <> 'null';

Select count(t1.order_id) No_Change
from customer_orders t1
full join runner_orders t3
on t1.order_id = t3.order_id
where exclusions = 'null' and extras = 'null';

-- How many pizzas were delivered that had both exclusions and extras?
Select count(t1.order_id) Contains_Both
from customer_orders t1
full join runner_orders t3
on t1.order_id = t3.order_id
where exclusions <> 'null' and extras <> 'null';

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT Case
when EXTRACT(HOUR FROM order_time) = 11 then '11a.m'
when EXTRACT(HOUR FROM order_time) = 18 then '6p.m'
when EXTRACT(HOUR FROM order_time) = 19 then '7p.m'
when EXTRACT(HOUR FROM order_time) = 13 then '1p.m'
when EXTRACT(HOUR FROM order_time) = 21 then '9p.m'
else '11p.m'
end as Order_hour
, count(order_id) AS total_pizza_volume
FROM customer_orders
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY total_pizza_volume desc;

-- What was the volume of orders for each day of the week?
SELECT case
when EXTRACT(Day FROM order_time) = 1 then '1st'
when EXTRACT(Day FROM order_time) = 2 then '2nd'
when EXTRACT(Day FROM order_time) = 4 then '4th'
when EXTRACT(Day FROM order_time) = 8 then '8th'
when EXTRACT(Day FROM order_time) = 9 then '9th'
when EXTRACT(Day FROM order_time) = 10 then '10th'
else '11th'
end order_day
, count(order_id) AS pizza_volume
FROM customer_orders
GROUP BY EXTRACT(day FROM order_time)
ORDER BY pizza_volume desc;

