SELECT *
FROM customer_transactions;

-- DATA CLEANING

-- CREATE AN IDENTICAL TABLE TO LEAVE THE ORIGINAL TABLE RAW AND RENAMING THE COLUMNS
CREATE TABLE `ct_staging` (
  `Transaction_ID` int DEFAULT NULL,
  `First_Name` text,
  `Last_Name` text,
  `Gender` text,
  `Birthdate` text,
  `Transaction_Amount` double DEFAULT NULL,
  `Date` text,
  `Merchant_Name` text,
  `Category` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM ct_staging;

INSERT ct_staging
SELECT *
FROM customer_transactions;

-- CHECKING DUPLICATES
WITH duplicate_test AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Transaction_ID) AS row_num
FROM ct_staging
)
SELECT *
FROM duplicate_test
WHERE row_num > 1;

-- CREATING TABLE THAT HAS A COLUMN NAMED ROW_NUM THAT TELLS US IF THERE IS ANY DUPLICATES
CREATE TABLE `ct_staging2` (
  `Transaction_ID` int DEFAULT NULL,
  `First_Name` text,
  `Last_Name` text,
  `Gender` text,
  `Birthdate` text,
  `Transaction_Amount` double DEFAULT NULL,
  `Date` text,
  `Merchant_Name` text,
  `Category` text,
  `Row_Num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO ct_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Transaction_ID) AS row_num
FROM ct_staging;

SELECT *
FROM ct_staging2;

SELECT DISTINCT Row_Num
FROM ct_staging2;

-- REMOVING DUPLICATES (IF THERE IS ANY)
DELETE
FROM ct_staging2
WHERE Row_Num > 1;

-- REMOVING ROW_NUM COLUMN
ALTER TABLE ct_staging2
DROP COLUMN Row_Num;

-- STANDARDIZING
-- CHECKING INCONSISTENT VALUES
SELECT DISTINCT Merchant_Name
FROM ct_staging2
ORDER BY 1;

SELECT DISTINCT Category
FROM ct_staging2
ORDER BY 1;

-- TRIMMING VALUES
UPDATE ct_staging2
SET First_Name = TRIM(First_Name);

UPDATE ct_staging2
SET Last_Name = TRIM(Last_Name);

UPDATE ct_staging2
SET Merchant_Name = TRIM(Merchant_Name);

UPDATE ct_staging2
SET Category = TRIM(Category);

-- FIXING DATE FORMAT
UPDATE ct_staging2
SET Birthdate = STR_TO_DATE(Birthdate, '%m/%d/%Y');

ALTER TABLE ct_staging2
MODIFY COLUMN Birthdate DATE;

UPDATE ct_staging2
SET `Date` = STR_TO_DATE(`Date`, '%m/%d/%Y');

ALTER TABLE ct_staging2
MODIFY COLUMN `Date` DATE;

-- CHECKING IF THERE IS ANY NULL OR BLANK VALUES ON IMPORTANT COLUMNS
SELECT *
FROM ct_staging2
WHERE Gender IS NULL
OR Gender = '';

SELECT *
FROM ct_staging2
WHERE Customer_ID IS NULL
OR Customer_ID = '';

SELECT *
FROM ct_staging2
WHERE Transaction_Amount IS NULL
OR Transaction_Amount = '';

SELECT *
FROM ct_staging2
WHERE `Date` IS NULL
OR `Date` = '';

SELECT *
FROM ct_staging2
WHERE Merchant_Name IS NULL
OR Merchant_Name = '';

SELECT *
FROM ct_staging2
WHERE Category IS NULL
OR Category = '';

-- TURNING BLANK VALUES INTO NULL
UPDATE ct_staging2
SET Gender = NULL
WHERE Gender = '';

-- CLEANED DATASET
SELECT *
FROM ct_staging2;