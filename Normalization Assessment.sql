--Rahitha Jugale R (PL2005)

--NORMALIZATION Assignment

--Unit_details table
CREATE TABLE Unit_details(
	unit_id INT PRIMARY KEY,
	unit_type VARCHAR(10)
);

--Inserting data
INSERT INTO Unit_details VALUES (1, 'Piece')
INSERT INTO Unit_details VALUES (2, 'Box Pack')

-------------------------------------------------------------------------------------

--Shop_details table
CREATE TABLE Shop_details(
	shop_id INT PRIMARY KEY,
	shop_name VARCHAR(20)
);

--Inserting data
INSERT INTO Shop_details VALUES (1, 'Amal Stores')
INSERT INTO Shop_details VALUES (2, 'Jyothi Stores')
INSERT INTO Shop_details VALUES (3, 'Indira Stores')

-------------------------------------------------------------------------------------------

--Item_details table
CREATE TABLE Item_details(
	item_id INT PRIMARY KEY,
	item_name VARCHAR(20)
);

--Inserting data
INSERT INTO Item_details VALUES (1, 'Bar-One')
INSERT INTO Item_details VALUES (2, 'Kitkat')
INSERT INTO Item_details VALUES (3, 'Milkybar')
INSERT INTO Item_details VALUES (4, 'Munch')

---------------------------------------------------------------------------------------------------------

--Item_unit_details table
CREATE TABLE Item_unit_details(
	item_unit_id INT PRIMARY KEY,
	item_id INT NOT NULL,
	unit_id INT NOT NULL,
	unit_price INT
	CONSTRAINT fk_item_id FOREIGN KEY (item_id) REFERENCES Item_details(item_id),
	CONSTRAINT fk_unit_id FOREIGN KEY (unit_id) REFERENCES Unit_details(unit_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

--Inserting data
INSERT INTO Item_unit_details VALUES (1, 1, 1, 10)
INSERT INTO Item_unit_details VALUES (2, 1, 2, 280)
INSERT INTO Item_unit_details VALUES (3, 2, 1, 15)
INSERT INTO Item_unit_details VALUES (4, 2, 2, 420)
INSERT INTO Item_unit_details VALUES (5, 3, 1, 5)
INSERT INTO Item_unit_details VALUES (6, 3, 2, 140)
INSERT INTO Item_unit_details VALUES (7, 4, 1, 10)
INSERT INTO Item_unit_details VALUES (8, 4, 2, 280)


---------------------------------------------------------------------------------------------------
--Sales_details table
CREATE TABLE Sales_details(
	sales_id INT PRIMARY KEY,
	item_unit_id INT NOT NULL,
	shop_id INT NOT NULL,
	quantity INT,
	sale_date DATE,
	CONSTRAINT fk_item_unit_id FOREIGN KEY (item_unit_id) REFERENCES Item_unit_details(item_unit_id),
	CONSTRAINT fk_shop_id FOREIGN KEY (shop_id) REFERENCES Shop_details(shop_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

--Inserting data
INSERT INTO Sales_details VALUES (1, 1, 1, 100, '2018-10-05')
INSERT INTO Sales_details VALUES (2, 3, 1, 200, '2018-10-05')
INSERT INTO Sales_details VALUES (3, 5, 1, 50, '2018-10-05')
INSERT INTO Sales_details VALUES (4, 7, 1, 150, '2018-10-05')
INSERT INTO Sales_details VALUES (5, 2, 2, 10, '2018-10-10')
INSERT INTO Sales_details VALUES (6, 4, 2, 30, '2018-10-10')
INSERT INTO Sales_details VALUES (7, 6, 2, 40, '2018-10-10')
INSERT INTO Sales_details VALUES (8, 8, 2, 20, '2018-10-10')
INSERT INTO Sales_details VALUES (9, 2, 3, 50, '2018-09-15')
INSERT INTO Sales_details VALUES (10, 4, 3, 70, '2018-09-15')
INSERT INTO Sales_details VALUES (11, 6, 3, 30, '2018-10-10')
INSERT INTO Sales_details VALUES (12, 1, 1, 150, '2018-09-15')
INSERT INTO Sales_details VALUES (13, 3, 1, 250, '2018-09-15')
INSERT INTO Sales_details VALUES (14, 7, 1, 200, '2018-10-10')

SELECT* FROM Sales_details;


SELECT iu.item_unit_id, iu.item_id, i.item_name, iu.unit_id, iu.unit_price
FROM Item_details i
INNER JOIN Item_unit_details iu 
ON i.item_id = iu.item_id;

-----------------------------------------------------------------------------------------------------
--1. Find out which product created more revenue in the month of October.


CREATE VIEW vw_Total_Revenue_Oct
AS
SELECT DISTINCT i.item_name, MONTH(s.sale_date) AS sale_month, SUM(s.quantity * iu.unit_price) AS TotalRevenueOct
FROM Item_details i
INNER JOIN Item_unit_details iu 
ON i.item_id = iu.item_id
INNER JOIN Sales_details s 
ON iu.item_unit_id = s.item_unit_id
GROUP BY i.item_name, MONTH(s.sale_date)
HAVING MONTH(s.sale_date) = 10;

SELECT item_name, sale_month, TotalRevenueOct
FROM vw_Total_Revenue_Oct
WHERE TotalRevenueOct IN (SELECT MAX(TotalRevenueOct) FROM vw_Total_Revenue_Oct);

-------------------------------------------------------------------------------------------------
--2.Find out which product sold more in Amal Store in the month of October

CREATE VIEW vw_AmalStoreOct
AS
SELECT shop.shop_name, i.item_name, MONTH(s.sale_date) AS sale_month, SUM(s.quantity) AS TotalQuantitySold
FROM Item_details i
INNER JOIN Item_unit_details iu 
ON i.item_id = iu.item_id
INNER JOIN Sales_details s 
ON iu.item_unit_id = s.item_unit_id
INNER JOIN Shop_details shop 
ON s.shop_id = shop.shop_id
GROUP BY shop.shop_name, i.item_name, MONTH(s.sale_date)
HAVING shop.shop_name LIKE 'Amal Stores' AND MONTH(s.sale_date) = 10;

SELECT shop_name, item_name, sale_month, TotalQuantitySold
FROM vw_AmalStoreOct 
WHERE TotalQuantitySold IN (SELECT MAX(TotalQuantitySold) FROM vw_AmalStoreOct);

------------------------------------------------------------------------------------------------------------
--3. Find out which all products crossed revenue more than Rs 10,000/- in the month of October

SELECT item_name, sale_month, TotalRevenueOct
FROM vw_Total_Revenue_Oct
WHERE TotalRevenueOct > 10000;

---------------------------------------------------------------------------------------------------------------
--4. Find out the shop which can be selected for the best store award of Nestle for the month of October based on revenue.

CREATE VIEW vw_Shop_Total_Revenue_Oct
AS
SELECT DISTINCT shop.shop_name, MONTH(s.sale_date) AS sale_month, SUM(s.quantity * iu.unit_price) AS TotalRevenueOct
FROM Item_unit_details iu 
INNER JOIN Sales_details s 
ON iu.item_unit_id = s.item_unit_id
INNER JOIN Shop_details shop 
ON s.shop_id = shop.shop_id
GROUP BY  shop.shop_name, MONTH(s.sale_date)
HAVING MONTH(s.sale_date) = 10;

SELECT shop_name, sale_month, TotalRevenueOct
FROM vw_Shop_Total_Revenue_Oct
WHERE TotalRevenueOct IN (SELECT MAX(TotalRevenueOct) FROM vw_Shop_Total_Revenue_Oct);