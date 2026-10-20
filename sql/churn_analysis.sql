-- Step 0: Tell SQL Server which database to work in
use ChurnDB;

-- Step 1: Take a quick look at the table
-- Shows the first 5 customers with all columns, so we can see what the data looks like
select top 5 *
from Churn_Cleaned;


-- Step 2: Show only the columns we care about
-- A table with 22 columns is hard to read, so we pick just 5
-- CAST(... AS DECIMAL(10,2)) makes the bill show exactly 2 decimal places (like 29.85)
select top 5 customerID, tenure, Contract, cast(MonthlyCharges as decimal(10,2)) as MonthlyCharges , Churn 
from Churn_Cleaned;

-- Step 3: Count how many customers we have
-- This should match our Python data: 7043
select count(*) as Total_Customers
from Churn_Cleaned;

-- Step 4a: Count only the customers who LEFT the company
-- Churn = 1 means "left", Churn = 0 means "stayed"
select count(*) as Churned_Customers
from Churn_Cleaned
where Churn = 1;

-- Step 4b: Count only customers on a month-to-month contract

select count(*) as Month_to_Month_Customers
from Churn_Cleaned
where Contract = 'Month-to-Month';

-- Step 4c: Count customers who LEFT and were on a month-to-month contract
-- AND means a customer must match BOTH conditions to be counted

select count(*) as Churned_Month_To_Month
from Churn_Cleaned
where Churn = 1
and Contract = 'Month-to-Month'

--Step 5a: Who had stayed with the company the longest?
select top 5 customerID, tenure,Contract 
from Churn_Cleaned
Order by tenure DESC;

--Step 5b: Who is the newest-customer

select top 5 customerID, tenure, Contract 
from Churn_Cleaned
order by tenure ASC;

-- Lesson 5c: Which customers who LEFT were paying the highest bills?
-- WHERE keeps only customers who left (Churn = 1), then ORDER BY sorts them by bill
-- CAST makes the bill show exactly 2 decimal places
select top 5
       CustomerID,
       tenure,
       Contract,
       CAST(MonthlyCharges as decimal (10,2)) as MonthlyCharges
from Churn_Cleaned
where Churn=1
order by MonthlyCharges desc;

--Without mention decimal points
--select top 5 CustomerID, tenure,Contract,MonthlyCharges 
--from Churn_Cleaned
--where Churn = 1
--order by MonthlyCharges desc;

--Step 6a: How many customers are on each typr of contract
select Contract, 
       count(*) as customers
from Churn_Cleaned
group by Contract
order by Customers Desc

--Step 6b: How many customers are left each type of contract?
select Contract,
       count(*) as Churned_Customers
from Churn_Cleaned
where Churn = 1
group by Contract
order by Churned_Customers Desc;

-- Lesson 7a: What percentage of ALL customers left?
-- ChurnFlag is 1 for customers who left and 0 for those who stayed
select count(*) as Total_Customers,
       sum(ChurnFlag) as Churned_Customers,
       cast(sum(ChurnFlag) * 100.0/ count(*) as decimal(5,1)) as Chur_Rate_Pct
from Churn_Cleaned

-- Lesson 7b: Churn rate for EACH contract type

select Contract,
       COUNT(*) as Customers,
       Sum(ChurnFlag) as Churned_Customers,
       CAST(sum(ChurnFlag) * 100.0 / count(*) as decimal(5,1)) as Churn_Rate_Pct
from Churn_Cleaned
Group by Contract
order by Churn_Rate_Pct  desc;

-- Lesson 8: How much revenue do leaving customers bring in, compared with staying customers?

select churn,
       count(*) as Customers,
       CAST(sum(MonthlyCharges) as decimal(12,2)) as Total_Monthly_Revenue,
       cast(avg(MonthlyCharges) as decimal(10,2)) as Avg_MOnthly_Bill
from Churn_Cleaned
group by Churn;

-- Step 9a: How big is the high-risk group, and how many of them leave?
select count(*) as Customers,
       CAST(sum(ChurnFlag) * 100.0/ count(*) as decimal (5,1)) as Churn_Rate_Pct
from Churn_Cleaned
where Contract = 'Month-to-month'
  and tenure <= 12
  and InternetService = 'Fiber optic'

-- Step 9b: Retention call list

SELECT TOP 10
       customerID,
       tenure,
       CAST(MonthlyCharges AS DECIMAL(10,2)) AS MonthlyCharges,
       PaymentMethod
FROM Churn_Cleaned
WHERE Churn = 0
  AND Contract = 'Month-to-month'
  AND tenure <= 12
  AND InternetService = 'Fiber optic'
ORDER BY MonthlyCharges DESC;