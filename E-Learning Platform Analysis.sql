#Database Creation
CREATE DATABASE IF NOT EXISTS purchasedb;
USE purchasedb;
CREATE TABLE IF NOT EXISTS learners(
Learner_id INT PRIMARY KEY,
Full_name VARCHAR(100),
Country VARCHAR(100)
);
CREATE TABLE IF NOT EXISTS courses(
Course_id INT PRIMARY KEY,
Course_name VARCHAR(100),
Category VARCHAR(100),
Unit_price DECIMAL(10,2) 
);
CREATE TABLE IF NOT EXISTS purchases(
Purchase_id INT PRIMARY KEY,
Learner_id INT,
Course_id INT,
FOREIGN KEY(Learner_id) REFERENCES learners(Learner_id),
FOREIGN KEY(Course_id) REFERENCES courses(Course_id),
Quantity INT,
Purchase_Date DATE
);
#Data entry
INSERT INTO learners(Learner_id,Full_name,Country)
VALUES(101,'John','Canada'),
(102,'Sophia','Germany'),
(103,'David','France'),
(104,'James','Italy'),
(105,'Olivia','Japan'),
(106,'Sneha','India');
SELECT*FROM learners;

INSERT INTO courses(Course_id,Course_name,Category,Unit_price)
VALUES(301,' Business Intelligence','Business',5000),
(302,'Machine Learning','Data',10000),
(303,'Web development','Programming',8000),
(304,'Cloud Computing','Cloud',15000),
(305,'Deep Learning','Artificial Intelligence',20000),
(306,'SQL','Database',25000);
SELECT*FROM courses;

INSERT INTO purchases(Purchase_id,Learner_id,Course_id,Quantity,Purchase_Date)
VALUES(2001,101,301,2,'2025-09-28'),
(2002,102,302,Null,'2026-02-14'),
(2003,103,303,1,'2025-08-27'),
(2004,104,304,3,'2026-01-19'),
(2005,105,305,2,'2026-05-31'),
(2006,102,303,3,'2025-04-18'),
(2007,106,306,4,'2026-03-22'),
(2008,104,302,5,'2025-06-25');
SELECT*FROM purchases;
#Use of Joins:
SELECT
l.Learner_id,l.Full_name,c.Course_name,c.Category,p.Quantity,p.Purchase_date
FROM Learners AS l
INNER JOIN purchases as p
ON l.Learner_id=p.Learner_id
INNER JOIN courses AS c
ON p.Course_id=c.Course_id;

ALTER TABLE purchases
ADD Total_Amount DECIMAL(10,2);

UPDATE purchases AS p
INNER JOIN courses AS c
ON p.Course_id=c.Course_id
SET p.Total_Amount=COALESCE(p.Quantity,0)*c.Unit_Price;
SELECT*FROM purchases;

SELECT
l.Full_name AS Learner_name,
c.Course_name AS Course_name,
c.Category AS Course_category,
p.Quantity AS Quantity,
FORMAT(p.Total_Amount,2) AS Total_Amount,
p.Purchase_Date
FROM purchases AS p
INNER JOIN learners AS l
ON p.Learner_id=l.Learner_id
INNER JOIN courses AS c
ON p.Course_id=c.Course_id
ORDER BY p.Total_Amount DESC;

#Core Analytical Queries:
SELECT
l.Full_name AS Learner_name,
l.Country,
SUM(p.Total_Amount) AS Total_Spending
FROM learners AS l
INNER JOIN purchases AS p
ON l.Learner_id=p.Learner_id
GROUP BY
l.Learner_id,
l.Full_name,
l.Country;

SELECT
c.Course_Name AS Course_Name,
SUM(p.Quantity) AS Total_Quantity
FROM purchases AS p
INNER JOIN Courses AS C
ON p.Course_id=c.Course_id
GROUP BY
c.Course_id,
c.Course_Name
ORDER BY Total_Quantity DESC
Limit 3;

SELECT
c.Category AS Category,
SUM(p.Total_Amount) AS Total_Revenue,
COUNT(DISTINCT p.Learner_id) AS Unique_Learners
FROM purchases AS p
INNER JOIN courses AS c
ON p.Course_id=c.Course_id
GROUP BY c.Category;

SELECT
l.Learner_id,
l.Full_name AS Learner_name,
COUNT(DISTINCT c.Category) AS Category_Count
FROM learners AS l
INNER JOIN purchases AS p
ON l.Learner_id=p.Learner_id
INNER JOIN courses AS c
ON p.COurse_id=c.Course_id
GROUP BY
l.Learner_id,
l.Full_name
HAVING COUNT(DISTINCT c.Category)>1;

SELECT
c.Course_id,
c.Course_Name,
c.Category
FROM courses AS c
LEFT JOIN purchases AS p
ON c.Course_id=p.Course_id
WHERE p.Course_id IS NULL;

#Subqueries
SELECT
l.Learner_id,
l.Full_name AS Learner_Name,
SUM(p.Total_Amount) AS Total_Spending
FROM learners AS l
INNER JOIN purchases AS p
ON l.Learner_id=p.Learner_id
GROUP BY l.Learner_id,l.Full_name
HAVING SUM(p.Total_Amount)>(
SELECT AVG(Total_Spending)
FROM (
SELECT 
Learner_id,
SUM(Total_Amount) AS Total_Spending
FROM purchases 
GROUP BY Learner_id
)AS learner_Totals
);

SELECT Course_name,category,Unit_Price
FROM courses
 WHERE Unit_Price> ANY(
 SELECT Unit_Price
 FROM Courses
 WHERE Category='Data'
 );
 
 WITH learner_spending AS (
 SELECT
 l.Learner_id,
 l.Full_name,
 l.Country,
 SUM(p.Total_Amount) AS Total_Spending
 FROM learners AS l
 INNER JOIN purchases AS p
 ON l.Learner_id=p.Learner_id
 GROUP BY
 l.Learner_id,
 l.Full_name,
 l.Country
 )
 SELECT
 Learner_id,
 Full_name AS Learner_name,
 Country,
 Total_Spending
 FROM Learner_Spending AS ls
 WHERE Total_Spending>(
 SELECT AVG(ls2.Total_Spending)
 FROM learner_Spending AS ls2
 WHERE ls2.Country=ls.Country
 );
 
 #CTE
 WITH learner_spending AS (
 SELECT
 l.Learner_id,
 l.Full_name,
 SUM(p.Total_amount) AS Total_spending 
 FROM learners AS l 
 INNER JOIN purchases AS p
 ON l.Learner_id=p.Learner_id
 GROUP BY
 l.Learner_id,
 l.Full_name
 )
 SELECT
 Learner_id,
 Full_name AS Learner_name,
 Total_Spending
 FROM learner_spending
 WHERE Total_spending>10000; 
 
 #CASE Expression
 WITH learner_spending AS (
 SELECT
 l.Learner_id,
 l.Full_name,
 SUM(p.Total_amount) AS Total_spending 
 FROM learners AS l 
 INNER JOIN purchases AS p
 ON l.Learner_id=p.Learner_id
 GROUP BY
 l.Learner_id,
 l.Full_name
 )
 SELECT 
 Learner_id,
 Full_name AS Learner_name,
 Total_spending,
 CASE
 WHEN Total_spending>15000 THEN 'High value'
 WHEN Total_spending>=8000 THEN 'Medium value'
 ELSE 'Low value'
 END AS Spending_category
 FROM learner_spending;
 
 #Null Handling:
 SELECT
 c.Course_id,
 c.Course_name,
 COALESCE(COUNT(p.Purchase_id),0) AS Purchase_Count
 FROM courses AS c
 LEFT JOIN purchases AS p
 ON c.Course_id=p.Course_id
 GROUP BY
 c.Course_id,
 c.Course_name;
 
 #View
 CREATE VIEW Category_performance_view AS 
 SELECT
 c.category,
 SUM(p.Total_amount) AS Total_revenue,
 COUNT(*) AS Number_of_purchases,
 AVG(p.Total_amount) AS Average_revenue_per_purchase
 FROM courses AS c
 INNER JOIN purchases AS p
 ON c.course_id=p.course_id
 GROUP BY c.category;
 SELECT*FROM Category_performance_view;
 
 
 



 








 