-- DATASET
SELECT *
FROM ct_staging2;

-- QUESTIONS

-- 1. How many total transactions are in the dataset?
SELECT COUNT(Transaction_ID)
FROM ct_staging2;

-- 2. How many unique customers are there?
SELECT COUNT(DISTINCT CONCAT(First_Name, ' ', Last_Name))
FROM ct_staging2;

-- 3. What is the total transaction amount?
SELECT SUM(Transaction_Amount)
FROM ct_staging2;

-- 4. What is the average transaction amount?
SELECT AVG(Transaction_Amount)
FROM ct_staging2;

-- 5. What is the minimum and maximum transaction amount?
SELECT MIN(Transaction_Amount), MAX(Transaction_Amount)
FROM ct_staging2;

-- 6. What are all the different transaction categories?
SELECT DISTINCT Category
FROM ct_staging2;

-- 7. How many transactions are there for each category?
SELECT Category, COUNT(Transaction_ID)
FROM ct_staging2
GROUP BY Category;

-- 8. What is the total transaction amount for each category?
SELECT Category, SUM(Transaction_Amount)
FROM ct_staging2
GROUP BY Category;

-- 9. What is the average transaction amount for each category?
SELECT Category, AVG(Transaction_Amount)
FROM ct_staging2
GROUP BY Category;

-- 10. How many transactions were made by each gender?
SELECT Gender, COUNT(Transaction_ID)
FROM ct_staging2
GROUP BY Gender;