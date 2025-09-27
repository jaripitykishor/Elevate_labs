create database project;
use project;
show tables;
select * from samplesuperstore;
rename table samplesuperstore to sss;
select * from sss;
SELECT DISTINCT Category FROM sss;
SELECT COUNT(*) FROM sss;
SELECT SUM(Sales) AS TotalSales FROM sss;
SELECT AVG(Profit) AS AvgProfit FROM sss;
SELECT *  
FROM sss 
WHERE State = 'California' AND Sales > 500;
SELECT *
FROM SSS
WHERE Sales BETWEEN 100 AND 500
AND ProductName LIKE '%Table%';
SELECT ProductName, Sales
FROM sss
WHERE Sales > ANY (SELECT Sales
				   FROM sss
				   WHERE Region = 'West')AND ProductName LIKE 'C%';
SELECT ProductName, Profit
FROM sss WHERE Region = 'East'
EXCEPT
SELECT ProductName, Profit
FROM sss WHERE Region = 'West'
order by profit desc;
SELECT ProductName, SUM(Sales) AS TotalSales  
FROM sss  
GROUP BY ProductName  
ORDER BY TotalSales DESC  
LIMIT 5;
SELECT State, SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit  
FROM sss  
GROUP BY State  
HAVING SUM(Sales) > 10000;
SELECT ProductName, Sales, Profit, (Profit / Sales) * 100 AS ProfitMargin  
FROM sss
WHERE (Profit / Sales) * 100 > 20;
SELECT Region, SUM(Sales) AS TotalSales
FROM sss
GROUP BY Region
HAVING SUM(Sales) > 1000
ORDER BY TotalSales DESC;
SELECT ProductName, Sales
FROM sss
WHERE Sales > (SELECT AVG(Sales) FROM sss);
SELECT Region, SUM(Sales) AS TotalSales
FROM sss 
GROUP BY Region
HAVING SUM(Sales) = (SELECT MAX(TotalSales) FROM (SELECT Region, SUM(Sales) AS TotalSales
												  FROM sss
												  GROUP BY Region) AS Subquery);
SELECT ProductName, Sales
FROM sss
WHERE Sales = (
    SELECT MAX(Sales)
    FROM sss
    WHERE Region = 'East');
SELECT ProductName, Profit
FROM sss
WHERE Profit = (
    SELECT MAX(Profit)
    FROM sss
    WHERE Category = (
        SELECT Category
        FROM (SELECT Category, SUM(Profit) AS TotalProfit
              FROM sss
              GROUP BY Category
              ORDER BY TotalProfit DESC
              LIMIT 1
        ) AS TopCategory));

create table emp (empno int primary key, ename varchar(100) not null, job varchar(100) not null, mgr int, hiredate date not null, sal int not null, comm int,deptno int not null);
describe emp;
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno) 
VALUES
(7369, 'SMITH', 'CLERK', 7902, '1980-12-17', 800, NULL, 20),
(7499, 'ALLEN', 'SALESMAN', 7698, '1981-02-20', 1600, 300, 30),
(7521, 'WARD', 'SALESMAN', 7698, '1981-02-22', 1250, 500, 30),
(7566, 'JONES', 'MANAGER', 7839, '1981-04-02', 2975, NULL, 20),
(7654, 'MARTIN', 'SALESMAN', 7698, '1981-09-28', 1250, 1400, 30),
(7698, 'BLAKE', 'MANAGER', 7839, '1981-05-01', 2850, NULL, 30),
(7782, 'CLARK', 'MANAGER', 7839, '1981-06-09', 2450, NULL, 10),
(7788, 'SCOTT', 'ANALYST', 7566, '1982-12-09', 3000, NULL, 20),
(7839, 'KING', 'PRESIDENT', NULL, '1981-11-17', 5000, NULL, 10),
(7844, 'TURNER', 'SALESMAN', 7698, '1981-09-08', 1500, 0, 30),
(7876, 'ADAMS', 'CLERK', 7788, '1983-01-12', 1100, NULL, 20),
(7900, 'JAMES', 'CLERK', 7698, '1981-12-03', 950, NULL, 30),
(7902, 'FORD', 'ANALYST', 7566, '1981-12-03', 3000, NULL, 20),
(7934, 'MILLER', 'CLERK', 7782, '1982-01-23', 1300, NULL, 10);
select ename, category
from emp cross join sss;
CREATE VIEW Sales_Profit_By_Region_Category AS
SELECT 
    Region,
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM 
    sss
GROUP BY 
    Region, Category;
SELECT * FROM Sales_Profit_By_Region_Category
ORDER BY Region, Category;
SELECT 
    Region,
    Category,
    SUM(Sales) AS Total_Value,
    'Sales' AS Type
FROM sss
GROUP BY Region, Category
UNION
SELECT 
    Region,
    Category,
    SUM(Profit) AS Total_Value,
    'Profit' AS Type
FROM sss
GROUP BY Region, Category;





