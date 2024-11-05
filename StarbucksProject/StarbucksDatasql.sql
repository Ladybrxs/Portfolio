SELECT* 
FROM city;

SELECT* 
FROM customers;

SELECT* 
FROM products;

SELECT* 
FROM sales;

--Coffee Consumers Count
--How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT COUNT(DISTINCT(cu.customer_id)) AS ConsumersCount, ci.city_name, ROUND((ci.population*0.25/1000000),2) AS consumersperpopulation
FROM customers cu
INNER JOIN city ci
	ON ci.city_id = cu.city_id
GROUP BY ci.city_name, ci.population
ORDER  BY consumersperpopulation DESC;


--Total Revenue from Coffee Sales
--What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT ci.city_name, SUM(sa.total) AS total
FROM sales sa
JOIN customers cu
	ON sa.customer_id = cu.customer_id
JOIN city ci
	ON ci.city_id = cu.city_id
WHERE YEAR(sa.sale_date) = 2023
	AND DATEPART(QUARTER,sa.sale_date) = 4
GROUP BY ci.city_name
ORDER BY 2 DESC;


--Sales Count for Each Product
--How many units of each coffee product have been sold?
SELECT pr.product_name, COUNT(sa.sale_id) as totalorders
FROM products pr
LEFT JOIN sales sa
	ON sa.product_id = pr.product_id
GROUP BY pr.product_name
ORDER BY totalorders DESC;


--Average Sales Amount per City
--What is the average sales amount per customer in each city?
SELECT  ci.city_name, SUM(sa.total) AS total, COUNT(DISTINCT(sa.customer_id)) AS customer, SUM(sa.total)/COUNT(DISTINCT(sa.customer_id)) AS AvgperCustomer
FROM sales sa
JOIN customers cu
	ON sa.customer_id = cu.customer_id
JOIN city ci																	
	ON ci.city_id = cu.city_id				
GROUP BY ci.city_name
ORDER BY AvgperCustomer DESC;


--City Population and Coffee Consumers
--Provide a list of cities along with their populations and estimated coffee consumers.
WITH city_table AS
(
SELECT city_name, SUM(population) AS population, ROUND(((population)*0.25/1000000),2) AS estimatedconsumers
FROM city
GROUP BY city_name, city.population
),
customers_table AS
	(
SELECT ci.city_name, COUNT(DISTINCT(cu.customer_id)) AS unique_cx
FROM sales sa
JOIN customers cu
	ON sa.customer_id = cu.customer_id
JOIN city ci
	ON ci.city_id = cu.city_id
	GROUP BY ci.city_name
	)

SELECT customers_table.city_name, city_table.estimatedconsumers, customers_table.unique_cx
FROM city_table
JOIN customers_table
ON city_table.city_name = customers_table.city_name;

--Top Selling Products by City
--What are the top 3 selling products in each city based on sales volume?

SELECT ci.city_name, pr.product_name, SUM(total) AS salesvolumentotal
FROM sales sa
JOIN customers cu
	ON sa.customer_id = cu.customer_id
JOIN city ci
	ON ci.city_id = cu.city_id
JOIN products pr
	ON pr.product_id = sa.product_id
	GROUP BY ci.city_name, pr.product_name
	ORDER BY salesvolumentotal DESC;

SELECT pr.product_name, SUM(total)/pr.price AS salesvolumenquantity
FROM sales sa
JOIN customers cu
	ON sa.customer_id = cu.customer_id
JOIN city ci
	ON ci.city_id = cu.city_id
JOIN products pr
	ON pr.product_id = sa.product_id
	GROUP BY pr.product_name, pr.price
	ORDER BY salesvolumenquantity DESC;

SELECT  ci.city_name, pr.product_name, COUNT(sa.sale_id) AS salesvolumentotalorder, DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(sa.sale_id) DESC) AS RANK
FROM sales sa
JOIN customers cu
	ON sa.customer_id = cu.customer_id
JOIN city ci
	ON ci.city_id = cu.city_id
JOIN products pr
	ON pr.product_id = sa.product_id
	GROUP BY  ci.city_name, pr.product_name;

--Customer Segmentation by City
--How many unique customers are there in each city who have purchased coffee products?
SELECT * FROM products;

SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY ci.city_name;

--Average Sale vs Rent
--Find each city and their average sale per customer and avg rent per customer
WITH city_table AS
(

SELECT  ci.city_name, 
	COUNT(DISTINCT(sa.customer_id)) AS customer, 
	SUM(sa.total)/COUNT(DISTINCT(sa.customer_id)) AS AvgperCustomer
FROM sales sa
JOIN customers cu
	ON sa.customer_id = cu.customer_id
JOIN city ci																	
	ON ci.city_id = cu.city_id				
GROUP BY ci.city_name
),
city_rent
AS
(SELECT 
	city_name, 
	estimated_rent
FROM city
)
SELECT 
	cr.city_name,
	cr.estimated_rent,
	ct.customer,
	ct.AvgperCustomer,
	ROUND(CAST(cr.estimated_rent AS FLOAT)/ct.customer,2) AS Avgrentpercustomer
FROM city_rent cr
	JOIN city_table ct
	ON cr.city_name = ct.city_name
	ORDER BY 5 DESC;


--Monthly Sales Growth
--Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

WITH
monthly_sales
AS
(
	SELECT 
		ci.city_name,
		MONTH(sale_date) as month,
		YEAR(sale_date) as YEAR,
		SUM(s.total) as total_sale
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY ci.city_name, MONTH(sale_date), YEAR(sale_date)
	ORDER BY 1, 3, 2
),
growth_ratio
AS
(
		SELECT
			city_name,
			month,
			year,
			total_sale as cr_month_sale,
			LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale
		FROM monthly_sales
)

SELECT
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	ROUND(
		CAST((cr_month_sale - last_month_sale) AS float) / CAST(last_month_sale AS float) * 100, 2
	) AS growth_ratio

FROM growth_ratio
WHERE 
	last_month_sale IS NOT NULL	



--Market Potential Analysis
--Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
SELECT ci.city_name, SUM(s.total) AS total_sale, SUM(ci.estimated_rent) AS total_rent, COUNT(DISTINCT(c.customer_id)) AS total_customers, ROUND((CAST(ci.population AS FLOAT)*0.25/1000000),2) AS consumersperpopulation
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY ci.city_name, ci.population
	ORDER BY total_sale DESC;