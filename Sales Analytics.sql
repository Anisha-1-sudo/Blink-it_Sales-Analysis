-- 1. Create DB only if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'BLINKIT')
BEGIN
    CREATE DATABASE BLINKIT;
END;

-- 2. Use the DB
USE BLINKIT;

-- 3. Create table only if it doesn't exist
IF OBJECT_ID('dbo.BlinkitSales', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BlinkitSales (
        Item_Fat_Content VARCHAR(100),
        Item_Identifier VARCHAR(20),
        Item_Type VARCHAR(250),
        Outlet_Establishment_Year INT,
        Outlet_Identifier VARCHAR(50),
        Outlet_Location_Type VARCHAR(20),
        Outlet_Size VARCHAR(100),
        Outlet_Type VARCHAR(100),
        Item_Visibility FLOAT,
        Item_Weight FLOAT,
        Total_Sales FLOAT,
        Rating FLOAT
    );
END

-- 4. Insert only if table is empty
IF NOT EXISTS (SELECT 1 FROM dbo.BlinkitSales)
BEGIN
    BULK INSERT dbo.BlinkitSales
    FROM 'C:\Users\mdsaq\Desktop\SQL Queries\Blinkit Projects\BlinkIT Grocery Data.csv'  -- USE Your Data Path for BULK Upload
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );
END;



--------------------------------------------------------------------------------------------------------------------------------
											---------------- ANALYTICS OVER DATA ------------------------


								----------------DATA CLEANING,STANDIZATION AND NORMALIZATION ---------------
--SELECT DISTINCT Item_Fat_Content FROM dbo.BlinkitSales;

UPDATE dbo.BlinkitSales
SET Item_Fat_Content = CASE WHEN LOWER(Item_Fat_Content) IN ('lf','low fat') THEN 'Low Fat'
							WHEN LOWER(Item_Fat_Content) = 'reg' THEN 'Regular'
							ELSE Item_Fat_Content END;


-- Find The Total Sales:

SELECT ROUND(SUM(Total_Sales),0) as 'Total Sales' FROM dbo.BlinkitSales;

--INSIGHTS :Total Sales = $1,20,1681


-- Find The Total Sales In Millions for Low Fat Contents:
SELECT CAST(SUM(Total_Sales)/1000000 AS DECIMAL(10,2)) as 'Total Sales in Million for Low Fat' FROM dbo.BlinkitSales
WHERE Item_Fat_Content = 'Low Fat';

--INSIGHTS : $ 0.78 Millions Of Sales


-- Find The Average Sales In Millions for Low Fat Contents:
SELECT CAST(AVG(Total_Sales)/1000000 AS DECIMAL(10,10)) as 'Average Sales in Millions' FROM dbo.BlinkitSales

--INSIGHTS : $ 0.0001409928 Millions Of Average Sales

---- Find The Total Number of Items

SELECT COUNT(1) as 'Total Number of Items' FROM dbo.BlinkitSales

--INSIGHTS : Total Item Count is 8523


--FIND THE TOTAL SALES In MILLION IN YEAR 2022

SELECT CAST(SUM(Total_Sales)/1000000 as DECIMAL(10,2)) as 'Total Sales In Million in Year 2022' FROM BlinkitSales
WHERE Outlet_Establishment_Year = 2022;

		--INSIGHTS :  TOTAL SALES In MILLION IN YEAR 2022 is $ 0.13 

--FIND THE AVERAGE RATING FROM OF all Deliveries

SELECT CAST(AVG(Rating) as DECIMAL (10,2)) AS 'Average Rating of Deliveries' FROM BlinkitSales

			--INSIGHTS :  Average Rating of all Deliveries is 3.97 

--FIND TOTAL SALES,AVERAGE SALES,Total Items & AVERAGE RATING as Per Item Fat Content Means both for Regular and Low Fat

SELECT Item_Fat_Content , 
		CAST(SUM(Total_Sales) AS DECIMAL(10,2)) as 'Total Sales',
		CAST(AVG(Total_Sales) AS DECIMAL(10,2)) as 'Average Sales',
		COUNT(Item_Fat_Content) as 'Item Count',
		CAST(AVG(Rating) AS DECIMAL(10,2)) as 'Average Ratings'
FROM BlinkitSales
GROUP BY Item_Fat_Content
ORDER BY 'Total Sales' DESC

				--INSIGHTS :  Low Fat Content have Max Sales of $ 776319.38 out of $1,20,1681 .


--FIND TOTAL SALES in Thousand,AVERAGE SALES,Total Items & AVERAGE RATING as Per Item Fat Content Means both for Regular and Low Fat

SELECT Item_Fat_Content , 
		CAST(SUM(Total_Sales)/1000 AS DECIMAL(10,2)) as 'Total Sales in Thousand',
		CAST(AVG(Total_Sales) AS DECIMAL(10,2)) as 'Average Sales',
		COUNT(Item_Fat_Content) as 'Item Count',
		CAST(AVG(Rating) AS DECIMAL(10,2)) as 'Average Ratings'
FROM BlinkitSales
GROUP BY Item_Fat_Content
ORDER BY 'Total Sales in Thousand' DESC

			--INSIGHTS :  Low Fat Content have Max Sales of $ 776k out of $1,20,1681 and Having Total Item of 5517 Units.				

--FIND TOTAL SALES,AVERAGE SALES,Total Items & AVERAGE RATING as Per Item Type Means

SELECT Item_Type , 
		CAST(SUM(Total_Sales) AS DECIMAL(10,2)) as 'Total Sales by Item Type',
		CAST(AVG(Total_Sales) AS DECIMAL(10,2)) as 'Average Sales',
		COUNT(Item_Fat_Content) as 'Item Count',
		CAST(AVG(Rating) AS DECIMAL(10,2)) as 'Average Ratings'
FROM BlinkitSales
GROUP BY Item_Type
ORDER BY 'Total Sales by Item Type' DESC

	--INSIGHTS : Item Type : Fruits and Vegetables have Max Sales of $178124.08 Followed by Snacks Foods, Household and Frozen Foods


--FIND TOTAL SALES in Thousand,AVERAGE SALES,Total Items & AVERAGE RATING as Per Item Type Means

SELECT Item_Type , 
		CAST(SUM(Total_Sales)/1000 AS DECIMAL(10,2)) as 'Total Sales In Thousand by Item Type',
		CAST(AVG(Total_Sales) AS DECIMAL(10,2)) as 'Average Sales',
		COUNT(Item_Fat_Content) as 'Item Count',
		CAST(AVG(Rating) AS DECIMAL(10,2)) as 'Average Ratings'
FROM BlinkitSales
GROUP BY Item_Type
ORDER BY 'Total Sales In Thousand by Item Type' DESC

--INSIGHTS : Item Type : Fruits and Vegetables have Max Sales of $178k Followed by Snacks Foods, Household and Frozen Foods

--FIND TOTAL SALES,AVERAGE SALES,Total Items & AVERAGE RATING as Per Outlet Location Type and Fat Content Type

SELECT Outlet_Location_Type , Item_Fat_Content,
		CAST(SUM(Total_Sales) AS DECIMAL(10,2)) as 'Total Sales In by Outlet_Location_Type  & Item_Fat_Content',
		CAST(AVG(Total_Sales) AS DECIMAL(10,2)) as 'Average Sales',
		COUNT(Item_Fat_Content) as 'Item Count',
		CAST(AVG(Rating) AS DECIMAL(10,2)) as 'Average Ratings'
FROM BlinkitSales
GROUP BY Outlet_Location_Type , Item_Fat_Content
ORDER BY 'Total Sales In by Outlet_Location_Type  & Item_Fat_Content' DESC

--INSIGHTS : Outlet Type Tier 3 has Max Sales in Both Fat Content Category ,Simultaneously have Max Item Counts


--FInd the Total Sales by Item_Fat Content at Each Outlet Location Type

SELECT Outlet_Location_Type,
	ROUND(SUM(CASE WHEN Item_Fat_Content = 'Low Fat' THEN Total_Sales ELSE 0 END),2) as 'Total Low Fat Sales' ,
	ROUND(SUM(CASE WHEN Item_Fat_Content = 'Regular' THEN Total_Sales ELSE 0 END),2) as 'Total Regular Sales' 
FROM BlinkitSales
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;

--INSIGHTS : Outlet Location TYpe : Tier 3 City Outlets have Highest Sales In both Fat Content Category followed by Tier 2 and Tier 1


--FIND THE TOTAL SALES by Outlet Size,Sales % Contribution by Outlet Size(Medium, Small And High)

SELECT Outlet_Size,
	ROUND(SUM(Total_Sales),2) as 'Total Sales per Outlet Size',
	ROUND(SUM(Total_Sales) * 100 /(SELECT SUM(Total_Sales) FROM BlinkitSales),2) as 'Sales % Contribution'
FROM BlinkitSales
GROUP BY Outlet_Size
ORDER BY 'Total Sales per Outlet Size' DESC

--INSIGHTS : MEDIUM SIZE OUTLET HAVE 42 % Contribution in Total Sales and BIG size Outlet have Lowest Contribution in Sales (20%)


--Yearly Sales of BlinkIT

SELECT Outlet_Establishment_Year,
	ROUND(SUM(Total_Sales),2) as 'Yearly Total Sales'
FROM BlinkitSales
GROUP BY Outlet_Establishment_Year
ORDER BY 'Yearly Total Sales' DESC

--INSIGHTS : Oldest Outlet have Largest Sales (The OUTLET ESTABLISHED IN YEAR 1998)


--FIND THE TOTAL SALES by Outlet Type,Sales % Contribution by Outlet Type(SuperMarket Type 1,2,3 & Grocery Store)

SELECT Outlet_Type,
	ROUND(SUM(Total_Sales),2) as 'Total Sales per Outlet Type',
	ROUND(SUM(Total_Sales) * 100 /(SELECT SUM(Total_Sales) FROM BlinkitSales),2) as 'Sales % Contribution'
FROM BlinkitSales
GROUP BY Outlet_Type
ORDER BY 'Total Sales per Outlet Type' DESC;

--INSIGHTS : SuperMarket Type1 Outlet Type have High Contribution in the Total Sales



-- FIND Total Sales by each Outlet, Average Sales by Each Outlet , and Count of Item Each Outlet and Its % Contribution in in Total Sales

SELECT Outlet_Identifier,
		ROUND(SUM(Total_Sales),2) as 'Total Sales by Each Outlet',
		ROUND(AVG(Total_Sales),2) as 'Average Sales by Each Outlet',
		COUNT(1) as 'Item Count by Each Outlet',
		ROUND(SUM(Total_Sales) * 100 /(SELECT SUM(Total_Sales) FROM BlinkitSales),2) as 'Sales % Contribution'
FROM BlinkitSales
GROUP BY Outlet_Identifier
ORDER BY 'Total Sales by Each Outlet' DESC

--INSIGHTS : Outlet OUT010 and OUT019 is Having Less Contribution as compare to other Outlets Due to Less Item Count at those Outlets But Having Similar Average Sales

-- FIND Average Sales by Fat Content ,Avg Rating by Fat Content

SELECT Item_Fat_Content,
	ROUND(AVG(Total_Sales),2) as 'Average Sales by Fat Content',
	ROUND(AVG(Rating),2) as 'Average Ratings by Fat Content'
FROM BlinkitSales
GROUP BY Item_Fat_Content
ORDER BY 'Average Sales by Fat Content' DESC

--INSIGHTS : NO DIFFERENCE IN AVERAGE RATING  or Sales WHETHERS Regular Fat Content OR Low Fat Content


---------------------------------------END OF DOCUMENT -----------------------------------------------------------------------------------------------------------


