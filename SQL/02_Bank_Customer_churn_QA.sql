-- ======================================================================
--                 BANK CUSTOMER CHURN ANALYSIS
--         Analytical CRM Development for a Bank (Capstone)
-- ======================================================================

-- ======================================================================
-- OBJECTIVE QUESTIONS
-- ======================================================================

-- OBJECTIVE Q1
-- What is the distribution of account balances across different regions?
-- ------------------------------------------------------------
SELECT g.GeographyLocation AS Region,
COUNT(*) AS Customers,
SUM(b.Balance = 0) AS Zero_Balance_Customers,
ROUND(MIN(b.Balance), 2) AS Min_Balance,
ROUND(AVG(b.Balance), 2) AS Avg_Balance,
ROUND(MAX(b.Balance), 2) AS Max_Balance,
ROUND(SUM(b.Balance), 2) AS Total_Balance,
ROUND(SUM(b.Balance) * 100 / SUM(SUM(b.Balance)) OVER (), 2) AS Pct_Of_Total_Balance
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
JOIN geography g    ON g.GeographyID = c.GeographyID
GROUP BY g.GeographyLocation
ORDER BY Total_Balance DESC;



-- OBJECTIVE Q2
-- Identify the top 5 customers with the highest Estimated Salary in the last quarter of the
-- year. (SQL)
-- ------------------------------------------------------------
-- Last quarter = customers whose Bank_DOJ falls in Oct-Dec (any year)
SELECT c.CustomerId, c.Surname, c.Bank_DOJ, c.EstimatedSalary
FROM customerinfo c
WHERE QUARTER(c.Bank_DOJ) = 4
ORDER BY c.EstimatedSalary DESC
LIMIT 5;


-- OBJECTIVE Q3
-- Calculate the average number of products used by customers who have a credit card. (SQL)
-- ------------------------------------------------------------
SELECT COUNT(*) AS Card_Holders,
ROUND(AVG(NumOfProducts), 2) AS Avg_Products
FROM bank_churn
WHERE HasCrCard = 1;


-- OBJECTIVE Q4
-- Determine the churn rate by gender for the most recent year in the dataset.
-- ------------------------------------------------------------
-- Most recent year = latest year of Bank_DOJ in the data (2019)
SELECT gd.GenderCategory AS Gender,
COUNT(*) AS Customers,
SUM(b.Exited) AS Exited,
ROUND(SUM(b.Exited) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM customerinfo c
JOIN bank_churn b ON b.CustomerId = c.CustomerId
JOIN gender gd    ON gd.GenderID  = c.GenderID
WHERE YEAR(c.Bank_DOJ) = (SELECT MAX(YEAR(Bank_DOJ)) FROM customerinfo)
GROUP BY gd.GenderCategory
ORDER BY Churn_Rate_Pct DESC;


-- OBJECTIVE Q5
-- Compare the average credit score of customers who have exited and those who remain. (SQL)
-- ------------------------------------------------------------
SELECT e.ExitCategory AS Status,
COUNT(*) AS Customers,
ROUND(AVG(b.CreditScore), 2) AS Avg_Credit_Score
FROM bank_churn b
JOIN exitcustomer e ON e.ExitID = b.Exited
GROUP BY e.ExitCategory;


-- OBJECTIVE Q6
-- Which gender has a higher average estimated salary, and how does it relate to the number
-- of active accounts? (SQL)
-- ------------------------------------------------------------
SELECT gd.GenderCategory AS Gender,
COUNT(*) AS Customers,
ROUND(AVG(c.EstimatedSalary), 2) AS Avg_Estimated_Salary,
SUM(b.IsActiveMember) AS Active_Accounts,
ROUND(SUM(b.IsActiveMember) * 100.0 / COUNT(*), 2) AS Active_Pct
FROM customerinfo c
JOIN bank_churn b ON b.CustomerId = c.CustomerId
JOIN gender gd ON gd.GenderID  = c.GenderID
GROUP BY gd.GenderCategory
ORDER BY Avg_Estimated_Salary DESC;


-- OBJECTIVE Q7
-- Segment the customers based on their credit score and identify the segment with the
-- highest exit rate. (SQL)
-- ------------------------------------------------------------
WITH seg AS (
  SELECT Exited,
         CASE WHEN CreditScore >= 800 THEN 'Excellent (800-850)'
              WHEN CreditScore >= 740 THEN 'Very Good (740-799)'
              WHEN CreditScore >= 670 THEN 'Good (670-739)'
              WHEN CreditScore >= 580 THEN 'Fair (580-669)'
              ELSE 'Poor (300-579)' END AS Credit_Segment
  FROM bank_churn
)
SELECT Credit_Segment,
COUNT(*) AS Customers,
SUM(Exited) AS Exited,
ROUND(SUM(Exited) * 100.0 / COUNT(*), 2) AS Exit_Rate_Pct
FROM seg
GROUP BY Credit_Segment
ORDER BY Exit_Rate_Pct DESC;


-- OBJECTIVE Q8
-- Find out which geographic region has the highest number of active customers with a tenure
-- greater than 5 years. (SQL)
-- ------------------------------------------------------------
SELECT g.GeographyLocation AS Region,
COUNT(*) AS Active_Customers_Tenure_Gt5
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
JOIN geography g    ON g.GeographyID = c.GeographyID
WHERE b.IsActiveMember = 1
  AND b.Tenure > 5
GROUP BY g.GeographyLocation
ORDER BY Active_Customers_Tenure_Gt5 DESC;


-- OBJECTIVE Q9
-- What is the impact of having a credit card on customer churn, based on the available data?
-- ------------------------------------------------------------
SELECT cc.Category AS Card_Status,
COUNT(*) AS Customers,
SUM(b.Exited) AS Exited,
ROUND(SUM(b.Exited) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churn b
JOIN creditcard cc ON cc.CreditID = b.HasCrCard
GROUP BY cc.Category;


-- OBJECTIVE Q10
-- For customers who have exited, what is the most common number of products they have used?
-- ------------------------------------------------------------
SELECT NumOfProducts,
COUNT(*) AS Exited_Customers,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Pct_Of_Exited
FROM bank_churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY Exited_Customers DESC;


-- OBJECTIVE Q11
-- Examine the trend of customers joining over time and identify any seasonal patterns
-- (yearly or monthly). Prepare the data through SQL and then visualize it.
-- ------------------------------------------------------------
-- Yearly trend with year-over-year growth
SELECT YEAR(Bank_DOJ) AS Join_Year,
COUNT(*) AS Customers_Joined,
ROUND((COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY YEAR(Bank_DOJ))) * 100.0 / LAG(COUNT(*)) OVER (ORDER BY YEAR(Bank_DOJ)), 2) AS YoY_Growth_Pct
FROM customerinfo
GROUP BY YEAR(Bank_DOJ)
ORDER BY Join_Year;


-- OBJECTIVE Q12
-- Analyze the relationship between the number of products and the account balance for
-- customers who have exited.
-- ------------------------------------------------------------
SELECT NumOfProducts,
COUNT(*) AS Exited_Customers,
SUM(Balance = 0) AS Zero_Balance,
ROUND(AVG(Balance), 2) AS Avg_Balance,
ROUND(SUM(Balance), 2) AS Total_Balance_Lost
FROM bank_churn
WHERE Exited = 1
GROUP BY NumOfProducts
ORDER BY NumOfProducts;


-- OBJECTIVE Q13
-- Identify any potential outliers in terms of balance among customers who have remained with
-- the bank.
-- ------------------------------------------------------------
-- IQR method: outlier if Balance < Q1 - 1.5*IQR or Balance > Q3 + 1.5*IQR
WITH retained AS (
  SELECT CustomerId, Balance,
  ROW_NUMBER() OVER (ORDER BY Balance) AS rn,
  COUNT(*) OVER () AS n
  FROM bank_churn
  WHERE Exited = 0
),
q AS (
  SELECT MAX(CASE WHEN rn = CEIL(0.25 * n) THEN Balance END) AS Q1,
         MAX(CASE WHEN rn = CEIL(0.75 * n) THEN Balance END) AS Q3
  FROM retained
)
SELECT q.Q1, q.Q3, (q.Q3 - q.Q1) AS IQR,
       ROUND(q.Q1 - 1.5 * (q.Q3 - q.Q1), 2) AS Lower_Fence,
       ROUND(q.Q3 + 1.5 * (q.Q3 - q.Q1), 2) AS Upper_Fence,
       SUM(r.Balance < q.Q1 - 1.5 * (q.Q3 - q.Q1)
        OR r.Balance > q.Q3 + 1.5 * (q.Q3 - q.Q1)) AS Outlier_Count,
       MAX(r.Balance) AS Max_Balance
FROM retained r CROSS JOIN q
GROUP BY q.Q1, q.Q3;

-- OBJECTIVE Q13b (supporting query)

-- Z-score check: retained customers more than 3 standard deviations from the mean
WITH stats AS (
  SELECT AVG(Balance) AS mu, STDDEV_POP(Balance) AS sd
  FROM bank_churn WHERE Exited = 0
)
SELECT b.CustomerId, b.Balance,
       ROUND((b.Balance - s.mu) / s.sd, 2) AS Z_Score
FROM bank_churn b CROSS JOIN stats s
WHERE b.Exited = 0
ORDER BY b.Balance DESC
LIMIT 5;


-- OBJECTIVE Q14
-- How many different tables are given in the dataset, out of these tables which table only
-- consists of categorical variables?
-- ------------------------------------------------------------
SELECT TABLE_NAME,
COUNT(*) AS Column_Count,
GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION SEPARATOR ', ') AS Columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bank_crm'
GROUP BY TABLE_NAME
ORDER BY Column_Count DESC, TABLE_NAME;


-- OBJECTIVE Q15
-- Using SQL, write a query to find out the gender-wise average income of males and females
-- in each geography id. Also, rank the gender according to the average value. (SQL)
-- ------------------------------------------------------------
SELECT c.GeographyID,
g.GeographyLocation,
gd.GenderCategory AS Gender,
ROUND(AVG(c.EstimatedSalary), 2) AS Avg_Income,
RANK() OVER (PARTITION BY c.GeographyID ORDER BY AVG(c.EstimatedSalary) DESC) AS Gender_Rank
FROM customerinfo c
JOIN gender gd    ON gd.GenderID    = c.GenderID
JOIN geography g  ON g.GeographyID  = c.GeographyID
GROUP BY c.GeographyID, g.GeographyLocation, gd.GenderCategory
ORDER BY c.GeographyID, Gender_Rank;


-- OBJECTIVE Q16
-- Using SQL, write a query to find out the average tenure of the people who have exited in
-- each age bracket (18-30, 30-50, 50+).
-- ------------------------------------------------------------
-- Brackets made non-overlapping: 18-30, 31-50, 51+
SELECT CASE WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
WHEN c.Age BETWEEN 31 AND 50 THEN '31-50'
ELSE '50+' END AS Age_Bracket,
COUNT(*) AS Exited_Customers,
ROUND(AVG(b.Tenure), 2) AS Avg_Tenure
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
WHERE b.Exited = 1
GROUP BY Age_Bracket
ORDER BY Age_Bracket;


-- OBJECTIVE Q17
-- Is there any direct correlation between salary and the balance of the customers? And is it
-- different for people who have exited or not?
-- ------------------------------------------------------------
-- Pearson correlation r = (nΣxy - ΣxΣy) / sqrt((nΣx² - (Σx)²)(nΣy² - (Σy)²))
SELECT COALESCE(e.ExitCategory, 'All Customers') AS Customer_Group,
COUNT(*) AS Customers,
ROUND((COUNT(*) * SUM(c.EstimatedSalary * b.Balance) - SUM(c.EstimatedSalary) * SUM(b.Balance)) / (SQRT(COUNT(*) * SUM(c.EstimatedSalary * c.EstimatedSalary) - POW(SUM(c.EstimatedSalary), 2))
* SQRT(COUNT(*) * SUM(b.Balance * b.Balance) - POW(SUM(b.Balance), 2))), 4) AS Corr_Salary_Balance
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
JOIN exitcustomer e ON e.ExitID     = b.Exited
GROUP BY e.ExitCategory WITH ROLLUP;


-- OBJECTIVE Q18
-- Is there any correlation between the salary and the Credit score of customers?
-- ------------------------------------------------------------
SELECT COUNT(*) AS Customers,
ROUND((COUNT(*) * SUM(c.EstimatedSalary * b.CreditScore) - SUM(c.EstimatedSalary) * SUM(b.CreditScore))
/ (SQRT(COUNT(*) * SUM(c.EstimatedSalary * c.EstimatedSalary) - POW(SUM(c.EstimatedSalary), 2))
* SQRT(COUNT(*) * SUM(b.CreditScore * b.CreditScore) - POW(SUM(b.CreditScore), 2))), 4) AS Corr_Salary_CreditScore
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId;


-- OBJECTIVE Q19
-- Rank each bucket of credit score as per the number of customers who have churned the bank.
-- ------------------------------------------------------------
WITH seg AS (
  SELECT CASE WHEN CreditScore >= 800 THEN 'Excellent (800-850)'
              WHEN CreditScore >= 740 THEN 'Very Good (740-799)'
              WHEN CreditScore >= 670 THEN 'Good (670-739)'
              WHEN CreditScore >= 580 THEN 'Fair (580-669)'
              ELSE 'Poor (300-579)' END AS Credit_Bucket
  FROM bank_churn
  WHERE Exited = 1
)
SELECT Credit_Bucket,
       COUNT(*) AS Churned_Customers,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS Churn_Rank
FROM seg
GROUP BY Credit_Bucket
ORDER BY Churn_Rank;


-- OBJECTIVE Q20
-- According to the age buckets find the number of customers who have a credit card. Also
-- retrieve those buckets that have lesser than average number of credit cards per bucket.
-- ------------------------------------------------------------
WITH bucket AS (
SELECT CASE WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
WHEN c.Age BETWEEN 31 AND 50 THEN '31-50'
ELSE '50+' END AS Age_Bucket,
SUM(b.HasCrCard) AS Card_Holders
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
GROUP BY Age_Bucket
)
SELECT Age_Bucket, Card_Holders,
ROUND(AVG(Card_Holders) OVER (), 2) AS Avg_Per_Bucket,
CASE WHEN Card_Holders < AVG(Card_Holders) OVER ()
THEN 'Below Average' ELSE 'Above Average' END AS Flag
FROM bucket
ORDER BY Age_Bucket;


-- OBJECTIVE Q21
-- Rank the Locations as per the number of people who have churned the bank and average
-- balance of the customers.
-- ------------------------------------------------------------
SELECT g.GeographyLocation AS Location,
SUM(b.Exited) AS Churned_Customers,
ROUND(AVG(b.Balance), 2) AS Avg_Balance,
RANK() OVER (ORDER BY SUM(b.Exited) DESC) AS Rank_By_Churn,
RANK() OVER (ORDER BY AVG(b.Balance) DESC) AS Rank_By_Avg_Balance
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
JOIN geography g    ON g.GeographyID = c.GeographyID
GROUP BY g.GeographyLocation
ORDER BY Rank_By_Churn;


-- OBJECTIVE Q22
-- As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have
-- to join it with a table where the primary key is also a combination of CustomerID and
-- Surname, come up with a column where the format is “CustomerID_Surname”.
-- ------------------------------------------------------------
SELECT CustomerId, Surname,
CONCAT(CustomerId, '_', Surname) AS CustomerID_Surname
FROM customerinfo
LIMIT 10;


-- OBJECTIVE Q23
-- Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn
-- table? If yes do this using SQL.
-- ------------------------------------------------------------
-- Correlated scalar subquery replaces the JOIN
SELECT b.CustomerId, b.Exited,
(SELECT e.ExitCategory
FROM exitcustomer e
WHERE e.ExitID = b.Exited) AS ExitCategory
FROM bank_churn b
LIMIT 10;


-- OBJECTIVE Q24
-- Were there any missing values in the data, using which tool did you replace them and what
-- are the ways to handle them?
-- ------------------------------------------------------------
SELECT 'bank_churn' AS Table_Name, COUNT(*) AS Total_Rows,
SUM(CustomerId IS NULL) + SUM(CreditScore IS NULL) + SUM(Tenure IS NULL) + SUM(Balance IS NULL)
+ SUM(NumOfProducts IS NULL) + SUM(HasCrCard IS NULL) + SUM(IsActiveMember IS NULL) + SUM(Exited IS NULL) AS Null_Cells
FROM bank_churn
UNION ALL
SELECT 'customerinfo', COUNT(*),
SUM(CustomerId IS NULL) + SUM(Surname IS NULL OR TRIM(Surname) = '') + SUM(Age IS NULL) + SUM(GenderID IS NULL)
+ SUM(EstimatedSalary IS NULL) + SUM(GeographyID IS NULL) + SUM(Bank_DOJ IS NULL)
FROM customerinfo;


-- OBJECTIVE Q25
-- Write the query to get the customer IDs, their last name, and whether they are active or
-- not for the customers whose surname ends with “on”.
-- ------------------------------------------------------------
SELECT c.CustomerId,
c.Surname AS Last_Name,
a.ActiveCategory AS Active_Status
FROM customerinfo c
JOIN bank_churn b ON b.CustomerId = c.CustomerId
JOIN activecustomer a ON a.ActiveID   = b.IsActiveMember
WHERE c.Surname LIKE '%on'
ORDER BY c.CustomerId;

-- OBJECTIVE Q25b (supporting query)

-- Summary of the same result set
SELECT a.ActiveCategory AS Active_Status, COUNT(*) AS Customers
FROM customerinfo c
JOIN bank_churn b ON b.CustomerId = c.CustomerId
JOIN activecustomer a ON a.ActiveID   = b.IsActiveMember
WHERE c.Surname LIKE '%on'
GROUP BY a.ActiveCategory;


-- OBJECTIVE Q26
-- Can you observe any data disrupency in the Customer’s data? As a hint it’s present in the
-- IsActiveMember and Exited columns. One more point to consider is that the data in the
-- Exited Column is absolutely correct and accurate.
-- ------------------------------------------------------------
SELECT a.ActiveCategory AS IsActiveMember,
SUM(b.Exited = 0) AS Retained,
SUM(b.Exited = 1) AS Exited,
COUNT(*) AS Total,
ROUND(SUM(b.Exited) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM bank_churn b
JOIN activecustomer a ON a.ActiveID = b.IsActiveMember
GROUP BY a.ActiveCategory;


-- ======================================================================
-- SUBJECTIVE QUESTIONS
-- ======================================================================

-- SUBJECTIVE Q1
-- Customer Behavior Analysis: What patterns can be observed in the spending habits of long-
-- term customers compared to new customers, and what might these patterns suggest about
-- customer loyalty?
-- ------------------------------------------------------------
SELECT CASE WHEN b.Tenure <= 4 THEN 'New (3-4 yrs)'
WHEN b.Tenure = 5  THEN 'Mid (5 yrs)'
ELSE 'Long-term (6-7 yrs)' END  AS Tenure_Group,
COUNT(*) AS Customers,
ROUND(AVG(b.Balance), 2) AS Avg_Balance,
ROUND(AVG(c.EstimatedSalary), 2) AS Avg_Salary,
ROUND(AVG(b.NumOfProducts), 2) AS Avg_Products,
ROUND(AVG(b.HasCrCard) * 100, 2) AS Card_Pct,
ROUND(AVG(b.IsActiveMember) * 100, 2) AS Active_Pct,
ROUND(AVG(b.Exited) * 100, 2) AS Churn_Rate_Pct
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
GROUP BY Tenure_Group
ORDER BY MIN(b.Tenure);


-- SUBJECTIVE Q2
-- Product Affinity Study: Which bank products or services are most commonly used together,
-- and how might this influence cross-selling strategies?
-- ------------------------------------------------------------
SELECT b.NumOfProducts,
cc.Category AS Card_Status,
COUNT(*) AS Customers,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Pct_Of_Base,
ROUND(AVG(b.Balance), 2) AS Avg_Balance,
ROUND(AVG(b.Exited) * 100, 2) AS Churn_Rate_Pct
FROM bank_churn b
JOIN creditcard cc ON cc.CreditID = b.HasCrCard
GROUP BY b.NumOfProducts, cc.Category
ORDER BY b.NumOfProducts, cc.Category;


-- SUBJECTIVE Q3
-- Geographic Market Trends: How do economic indicators in different geographic regions
-- correlate with the number of active accounts and customer churn rates?
-- ------------------------------------------------------------
SELECT g.GeographyLocation AS Region,
COUNT(*) AS Customers,
ROUND(AVG(c.EstimatedSalary), 2) AS Avg_Salary,
ROUND(AVG(b.Balance), 2) AS Avg_Balance,
ROUND(AVG(b.CreditScore), 1) AS Avg_Credit_Score,
SUM(b.IsActiveMember) AS Active_Accounts,
ROUND(AVG(b.IsActiveMember) * 100, 2) AS Active_Pct,
ROUND(AVG(b.Exited) * 100, 2) AS Churn_Rate_Pct
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
JOIN geography g    ON g.GeographyID = c.GeographyID
GROUP BY g.GeographyLocation
ORDER BY Churn_Rate_Pct DESC;


-- SUBJECTIVE Q4
-- Risk Management Assessment: Based on customer profiles, which demographic segments appear
-- to pose the highest financial risk to the bank, and why?
-- ------------------------------------------------------------
SELECT g.GeographyLocation AS Region,
gd.GenderCategory   AS Gender,
CASE WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
WHEN c.Age BETWEEN 31 AND 50 THEN '31-50'
ELSE '50+' END AS Age_Bracket,
COUNT(*) AS Customers,
ROUND(AVG(b.Exited) * 100, 2) AS Churn_Rate_Pct,
ROUND(SUM(b.Balance * b.Exited), 2) AS Balance_Lost,
ROUND(AVG(CASE WHEN b.Exited = 1 THEN b.Balance END), 2) AS Avg_Balance_Of_Churners
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
JOIN geography g    ON g.GeographyID = c.GeographyID
JOIN gender gd      ON gd.GenderID   = c.GenderID
GROUP BY Region, Gender, Age_Bracket
HAVING COUNT(*) >= 100
ORDER BY Churn_Rate_Pct DESC
LIMIT 8;


-- SUBJECTIVE Q5
-- Customer Tenure Value Forecast: How would you use the available data to model and predict
-- the lifetime (tenure) value in the bank of different customer segments?
-- ------------------------------------------------------------
-- Current value per segment: average balance x products x retention
SELECT CASE WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
WHEN c.Age BETWEEN 31 AND 50 THEN '31-50'
ELSE '50+' END AS Age_Bracket,
b.NumOfProducts,
COUNT(*) AS Customers,
ROUND(AVG(b.Tenure), 2) AS Avg_Tenure,
ROUND(AVG(b.Balance), 2) AS Avg_Balance,
ROUND(1 - AVG(b.Exited), 4) AS Retention_Rate,
ROUND(AVG(b.Balance) * (1 - AVG(b.Exited)), 2) AS Retention_Weighted_Balance
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
WHERE b.NumOfProducts <= 2
GROUP BY Age_Bracket, b.NumOfProducts
ORDER BY Retention_Weighted_Balance DESC;


-- SUBJECTIVE Q6
-- Marketing Campaign Effectiveness: How could you assess the impact of marketing campaigns
-- on customer retention and acquisition within the dataset? What extra information would you
-- need to solve this?
-- ------------------------------------------------------------
-- Acquisition + retention by join cohort (the only campaign proxy available)
SELECT YEAR(c.Bank_DOJ) AS Join_Year,
QUARTER(c.Bank_DOJ) AS Join_Quarter,
COUNT(*) AS Customers_Acquired,
ROUND(AVG(b.Exited) * 100, 2) AS Cohort_Churn_Pct
FROM customerinfo c
JOIN bank_churn b ON b.CustomerId = c.CustomerId
GROUP BY Join_Year, Join_Quarter
ORDER BY Join_Year, Join_Quarter;


-- SUBJECTIVE Q7
-- Customer Exit Reasons Exploration: Can you identify common characteristics or trends among
-- customers who have exited that could explain their reasons for leaving?
-- ------------------------------------------------------------
SELECT e.ExitCategory AS Status,
COUNT(*) AS Customers,
ROUND(AVG(c.Age), 1) AS Avg_Age,
ROUND(AVG(b.CreditScore), 1) AS Avg_Credit_Score,
ROUND(AVG(b.Balance), 2) AS Avg_Balance,
ROUND(AVG(c.EstimatedSalary), 2) AS Avg_Salary,
ROUND(AVG(b.NumOfProducts), 2) AS Avg_Products,
ROUND(AVG(b.IsActiveMember) * 100, 1) AS Active_Pct,
ROUND(AVG(c.GenderID = 2) * 100, 1) AS Female_Pct,
ROUND(AVG(c.GeographyID = 3) * 100, 1) AS Germany_Pct
FROM bank_churn b
JOIN customerinfo c ON c.CustomerId = b.CustomerId
JOIN exitcustomer e ON e.ExitID     = b.Exited
GROUP BY e.ExitCategory;


-- SUBJECTIVE Q8
-- Are 'Tenure', 'NumOfProducts', 'IsActiveMember', and 'EstimatedSalary' important for
-- predicting if a customer will leave the bank?
-- ------------------------------------------------------------
-- Churn-rate spread across the levels of each variable (bigger spread = stronger predictor)
WITH base AS (
  SELECT b.Exited, b.Tenure, b.NumOfProducts, b.IsActiveMember,
NTILE(4) OVER (ORDER BY c.EstimatedSalary) AS Salary_Quartile
FROM bank_churn b JOIN customerinfo c ON c.CustomerId = b.CustomerId
)
SELECT 'Tenure' AS Feature, CAST(Tenure AS CHAR) AS Level_, COUNT(*) AS Customers, ROUND(AVG(Exited)*100,2) AS Churn_Rate_Pct FROM base GROUP BY Tenure
UNION ALL
SELECT 'NumOfProducts', CAST(NumOfProducts AS CHAR), COUNT(*), ROUND(AVG(Exited)*100,2) FROM base GROUP BY NumOfProducts
UNION ALL
SELECT 'IsActiveMember', CAST(IsActiveMember AS CHAR), COUNT(*), ROUND(AVG(Exited)*100,2) FROM base GROUP BY IsActiveMember
UNION ALL
SELECT 'Salary Quartile', CONCAT('Q', Salary_Quartile), COUNT(*), ROUND(AVG(Exited)*100,2) FROM base GROUP BY Salary_Quartile;


-- SUBJECTIVE Q9
-- Utilize SQL queries to segment customers based on demographics and account details.
-- ------------------------------------------------------------
WITH seg AS (
SELECT b.CustomerId, b.Exited, b.Balance,
 CASE WHEN b.Balance = 0 AND b.NumOfProducts >= 2  THEN 'Engaged - No Balance'
 WHEN b.Balance >= 100000 AND b.IsActiveMember = 1 THEN 'High Value - Active'
 WHEN b.Balance >= 100000 AND b.IsActiveMember = 0 THEN 'High Value - Inactive'
 WHEN b.Balance = 0 THEN 'Dormant - Single Product'
 ELSE 'Mass Market' END AS Value_Segment,
 CASE WHEN c.Age BETWEEN 18 AND 30 THEN 'Young (18-30)'
 WHEN c.Age BETWEEN 31 AND 50 THEN 'Middle (31-50)'
 ELSE 'Senior (50+)' END AS Life_Stage
 FROM bank_churn b JOIN customerinfo c ON c.CustomerId = b.CustomerId
)
SELECT Value_Segment, Life_Stage,
COUNT(*) AS Customers,
ROUND(AVG(Balance), 2) AS Avg_Balance,
ROUND(AVG(Exited) * 100, 2) AS Churn_Rate_Pct
FROM seg
GROUP BY Value_Segment, Life_Stage
ORDER BY Value_Segment, Life_Stage;


-- SUBJECTIVE Q10
-- How can we create a conditional formatting setup to visually highlight customers at risk
-- of churn and to evaluate the impact of credit card rewards on customer retention?
-- ------------------------------------------------------------
-- Rule-based risk flag (feeds the Power BI conditional formatting)
WITH risk AS (
SELECT b.*, c.Age, c.GeographyID,
(c.Age BETWEEN 46 AND 65) + (b.IsActiveMember = 0) + (b.NumOfProducts >= 3)
+ (c.GeographyID = 3) + (b.NumOfProducts = 1 AND b.Balance > 0) AS Risk_Points
FROM bank_churn b JOIN customerinfo c ON c.CustomerId = b.CustomerId
)
SELECT CASE WHEN Risk_Points >= 3 THEN '1 High'
WHEN Risk_Points = 2  THEN '2 Medium'
ELSE '3 Low' END AS Risk_Level,
COUNT(*) AS Customers,
ROUND(AVG(Exited) * 100, 2) AS Actual_Churn_Pct,
ROUND(AVG(CASE WHEN HasCrCard = 1 THEN Exited END) * 100, 2) AS Churn_Pct_With_Card,
ROUND(AVG(CASE WHEN HasCrCard = 0 THEN Exited END) * 100, 2) AS Churn_Pct_No_Card
FROM risk
GROUP BY Risk_Level
ORDER BY Risk_Level;


-- SUBJECTIVE Q11
-- What is the current churn rate per year and overall as well in the bank? Can you suggest
-- some insights to the bank about which kind of customers are more likely to churn and what
-- different strategies can be used to decrease the churn rate?
-- ------------------------------------------------------------
SELECT CAST(YEAR(c.Bank_DOJ) AS CHAR) AS Join_Year,
COUNT(*) AS Customers,
SUM(b.Exited) AS Exited,
ROUND(SUM(b.Exited) * 100.0 / COUNT(*), 2)  AS Churn_Rate_Pct
FROM customerinfo c
JOIN bank_churn b ON b.CustomerId = c.CustomerId
GROUP BY CAST(YEAR(c.Bank_DOJ) AS CHAR)
UNION ALL
SELECT 'Overall', COUNT(*), SUM(Exited), ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)
FROM bank_churn
ORDER BY Join_Year;

-- SUBJECTIVE Q11b (supporting query)

-- Churn rate by age bracket and by activity (who churns most)
SELECT CASE WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN c.Age BETWEEN 31 AND 40 THEN '31-40'
            WHEN c.Age BETWEEN 41 AND 50 THEN '41-50'
            WHEN c.Age BETWEEN 51 AND 60 THEN '51-60'
            ELSE '60+' END AS Age_Band,
COUNT(*) AS Customers,
ROUND(AVG(b.Exited) * 100, 2) AS Churn_Rate_Pct
FROM bank_churn b JOIN customerinfo c ON c.CustomerId = b.CustomerId
GROUP BY Age_Band
ORDER BY Age_Band;

-- SUBJECTIVE Q14
-- In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to
-- “Has_creditcard”?
-- ------------------------------------------------------------
ALTER TABLE bank_churn RENAME COLUMN HasCrCard TO Has_creditcard;

-- Verify
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bank_crm' AND TABLE_NAME = 'bank_churn';

-- Rename back so the rest of the file keeps working
ALTER TABLE bank_churn RENAME COLUMN Has_creditcard TO HasCrCard;