SELECT * FROM swiggy_data

--Check NULL values each column
SELECT 
	SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
	SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
	SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
	SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
	SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
	SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
	SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price_inr,
	SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
	SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) null_rating_count
FROM swiggy_data

--Blank & Empty Strings
SELECT * FROM swiggy_data
WHERE State= '' OR City= '' OR Order_Date= '' OR Restaurant_Name= '' OR Location= '' OR Category= '' OR Dish_Name='';

--Duplicate Detection
SELECT State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name,
Price_INR, Rating, Rating_Count, COUNT(*) AS CNT FROM swiggy_data
GROUP BY  State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name,
Price_INR, Rating, Rating_Count
HAVING COUNT(*)> 1;


--Delete Duplication
WITH CTE AS(
	SELECT *, ROW_NUMBER() OVER( PARTITION BY State, City, Order_Date, Restaurant_Name, Location,
		Category, Dish_Name, Price_INR, Rating, Rating_Count ORDER BY (SELECT NULL)) AS rn 
	FROM swiggy_data
)
DELETE FROM CTE WHERE rn > 1;

-- Creating Schema
--Dimension Tables
--Date Table

IF OBJECT_ID('dim_date', 'U') IS NOT NULL
    DROP TABLE dbo.dim_date;

CREATE TABLE dim_date(
	date_id INT IDENTITY(1,1) PRIMARY KEY,
	Full_Date DATE,
	Year INT,
	Month INT,
	Day INT,
	Week INT,
	Quater INT,
	Month_Name VARCHAR(20)
)

--Location Table
IF OBJECT_ID('dim_location', 'U') IS NOT NULL
    DROP TABLE dbo.dim_location;

CREATE TABLE dim_location(
	location_id INT IDENTITY(1,1) PRIMARY KEY,
	State VARCHAR(100),
	City VARCHAR(100),
	Location VARCHAR(200)
);

--Restaurant Table
IF OBJECT_ID('dim_restaurant', 'U') IS NOT NULL
    DROP TABLE dbo.dim_restaurant;

CREATE TABLE dim_restaurant(
	restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
	Restaurant_Name VARCHAR(200)
);

--Category Table
IF OBJECT_ID('dim_category', 'U') IS NOT NULL
    DROP TABLE dbo.dim_category;

CREATE TABLE dim_category(
	category_id INT IDENTITY(1,1) PRIMARY KEY,
	category VARCHAR(200)
);

-- Dish Table
IF OBJECT_ID('dim_dish', 'U') IS NOT NULL
    DROP TABLE dbo.dim_dish;

CREATE TABLE dim_dish(
	dish_id INT IDENTITY(1,1) PRIMARY KEY,
	Dish_Name VARCHAR(200)
)



--Fact Table
IF OBJECT_ID('fact_wiggy_orders', 'U') IS NOT NULL
    DROP TABLE dbo.fact_swiggy_orders;

CREATE TABLE fact_swiggy_orders(
	order_id INT IDENTITY(1,1) PRIMARY KEY,
	date_id INT,
	Price_INR decimal(10,2),
	Rating decimal(4,2),
	Rating_Count INT,

	location_id INT,
	restaurant_id INT,
	category_id INT,
	dish_id INT,

	FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
	FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
	FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);


--Insert data into tables
-- dim_date
INSERT INTO dim_date (Full_Date, Year, Month, Month_Name, Quater, Day, Week)
SELECT DISTINCT
	Order_Date,
	YEAR(Order_Date),
	MONTH(Order_Date),
	DATENAME(MONTH,Order_Date),
	DATEPART(QUARTER, Order_Date),
	DAY(Order_Date),
	DATEPART(WEEK, Order_Date)
FROM swiggy_data
WHERE Order_Date IS NOT NULL

-- dim_location
INSERT INTO dim_location(State, City, Location)
SELECT DISTINCT
	State,
	City, 
	Location
FROM swiggy_data

--dim_restaurant
INSERT INTO dim_restaurant (Restaurant_Name)
SELECT DISTINCT
	Restaurant_Name
FROM swiggy_data

--dim_category
INSERT INTO dim_category(category)
SELECT DISTINCT
	Category
FROM swiggy_data

--dim_dish
INSERT INTO dim_dish(Dish_Name)
SELECT DISTINCT
	Dish_Name
FROM swiggy_data


--fact_swiggy_orders
INSERT INTO fact_swiggy_orders(
	date_id,
	Price_INR,
	Rating,
	Rating_Count,
	location_id,
	restaurant_id,
	category_id,
	dish_id
)
SELECT 
	dd.date_id,
	s.Price_INR,
	s.Rating,
	s.Rating_Count,

	dl.location_id,
	dr.restaurant_id,
	dc.category_id,
	dsh.dish_id
FROM Swiggy_Data AS s	

JOIN dim_date AS dd
	ON dd.Full_Date = s.Order_Date
	
JOIN dim_location AS dl
	ON dl.State = s.State
	AND dl.City = s.City
	AND dl.Location = s.Location

JOIN dim_restaurant AS dr
	ON dr.Restaurant_Name = s.Restaurant_Name

JOIN dim_category AS dc
	ON dc.category = s.Category

JOIN dim_dish AS dsh
	ON dsh.Dish_Name = s.Dish_Name


SELECT * FROM fact_swiggy_orders f
JOIN dim_category c ON c.category_id = f.category_id
JOIN dim_date d ON d.date_id = f.date_id
JOIN dim_dish dsh ON dsh.dish_id = f.dish_id
JOIN dim_location l ON l.location_id = f.location_id
JOIN dim_restaurant r ON r.restaurant_id = f.restaurant_id

--KPI's
-- Total Orders
SELECT COUNT(*) AS Total_Orders
FROM fact_swiggy_orders

-- Total Revenue (INR Million)
SELECT
	FORMAT(SUM(CONVERT(FLOAT, Price_INR))/ 1000000, 'N2') + 'INR Million' AS Total_Revenue
FROM fact_swiggy_orders

-- Average Dish Price
SELECT
	FORMAT(AVG(Price_INR), 'N2') + ' INR' AS Average_Dish_Price
FROM fact_swiggy_orders

-- Average Rating
SELECT
	FORMAT(AVG(Rating), 'n2') AS Average_Rating
FROM fact_swiggy_orders

--Deep-Dive business Analysis/ Granularity level
-- Monthly Orders Trends
SELECT
	Year,
	Month,
	Month_Name,
	COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY Year,
		Month,
		Month_Name
ORDER BY COUNT(*) DESC

--Monthly Revenue Trends
SELECT 
	Year,
	Month,
	Month_Name,
	FORMAT(SUM(CONVERT(FLOAT, Price_INR))/1000000, 'N2') + ' INR' AS Total_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY Year,
		Month,
		Month_Name
ORDER BY 
	FORMAT(SUM(CONVERT(FLOAT, Price_INR))/1000000, 'N2') + ' INR' DESC

-- Quaterly Order Trends 
SELECT 
	Year,
	Quater,
	COUNT(*) AS Total_Orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY Year, Quater
ORDER BY COUNT(*) DESC

