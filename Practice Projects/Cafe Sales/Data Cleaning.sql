SELECT *
FROM cafe_sales;

-- CREATING A BACKUP TABLE 
CREATE TABLE `sales_staging` (
  `Transaction_ID` text,
  `Item` text,
  `Quantity` int DEFAULT NULL,
  `Price_Per_Unit` double DEFAULT NULL,
  `Total_Spent` double DEFAULT NULL,
  `Payment_Method` text,
  `Location` text,
  `Transaction_Date` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO sales_staging
SELECT *
FROM cafe_sales;

SELECT *
FROM sales_staging;

-- FINDING OUT IF THERE ARE ANY DUPLICATES
WITH duplicate_test AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY Transaction_ID) as Row_Num
FROM sales_staging
)
SELECT COUNT(Row_Num)
FROM duplicate_test
WHERE Row_Num > 1;

-- REMOVING WHITE SPACES
UPDATE sales_staging
SET Transaction_ID = TRIM(Transaction_ID);

UPDATE sales_staging
SET Item = TRIM(Item);

UPDATE sales_staging
SET Payment_Method = TRIM(Payment_Method);

UPDATE sales_staging
SET Location = TRIM(Location);

-- CHECKING IF THERE ARE MISSPELLED WORDS
SELECT DISTINCT Item
FROM sales_staging;

SELECT DISTINCT Payment_Method
FROM sales_staging;

SELECT DISTINCT Location
FROM sales_staging;

-- CHECKING NULL, BLANKS, AND INVALID ENTRIES PER COLUMN
SELECT
    SUM(Transaction_ID IS NULL OR Transaction_ID = '' OR Transaction_ID = 'UNKNOWN' OR Transaction_ID = 'ERROR') AS Transaction_ID_Missing,
    SUM(Item IS NULL OR Item = '' OR Item = 'UNKNOWN' OR Item = 'ERROR') AS Item_Missing,
    SUM(Quantity IS NULL OR Quantity = '' OR Quantity = 'UNKNOWN' OR Quantity = 'ERROR') AS Quantity_Missing,
    SUM(Price_Per_Unit IS NULL OR Price_Per_Unit = '' OR Price_Per_Unit = 'UNKNOWN' OR Price_Per_Unit = 'ERROR') AS Price_Per_Unit_Missing,
    SUM(Total_Spent IS NULL OR Total_Spent = '' OR Total_Spent = 'UNKNOWN' OR Total_Spent = 'ERROR') AS Total_Spent_Missing,
    SUM(Payment_Method IS NULL OR Payment_Method = '' OR Payment_Method = 'UNKNOWN' OR Payment_Method = 'ERROR') AS Payment_Method_Missing,
    SUM(Location IS NULL OR Location = '' OR Location = 'UNKNOWN' OR Location = 'ERROR') AS Location_Missing,
    SUM(Transaction_Date IS NULL OR Transaction_Date = '' OR Transaction_Date = 'UNKNOWN' OR Transaction_Date = 'ERROR') AS Transaction_Date_Missing
FROM sales_staging;

-- CHANGING THE INVALID VALUES ON ITEM COLUMN DEPENDING ON THE PRICE_PER_UNIT COLUMN, KNOWING THAT THE PRICE OF EVERY ITEM IS GIVEN USING CASE STATEMENT

-- CHANGING INVALID VALUES WITH NaN TO PREVENT INCONSISTENCY
UPDATE sales_staging
SET 
	Item = CASE
				WHEN Item = 'UNKNOWN' THEN 'NaN'
                WHEN Item = 'ERROR' THEN 'NaN'
                WHEN Item = '' THEN 'NaN'
                WHEN Item IS NULL THEN 'NaN'
			ELSE Item
			END;

UPDATE sales_staging
SET 
	Payment_Method = CASE
				WHEN Payment_Method = 'UNKNOWN' THEN 'NaN'
                WHEN Payment_Method = 'ERROR' THEN 'NaN'
                WHEN Payment_Method = '' THEN 'NaN'
                WHEN Payment_Method IS NULL THEN 'NaN'
			ELSE Payment_Method
			END;

UPDATE sales_staging
SET 
	Location = CASE
				WHEN Location = 'UNKNOWN' THEN 'NaN'
                WHEN Location= 'ERROR' THEN 'NaN'
                WHEN Location = '' THEN 'NaN'
                WHEN Location IS NULL THEN 'NaN'
			ELSE Location
			END;

UPDATE sales_staging
SET 
	Transaction_Date = CASE
				WHEN Transaction_Date = 'UNKNOWN' THEN NULL
                WHEN Transaction_Date= 'ERROR' THEN NULL
                WHEN Transaction_Date = '' THEN NULL
			ELSE Transaction_Date
			END;

SELECT Transaction_Date, Transaction_ID
FROM sales_staging
ORDER BY Transaction_Date;

SELECT Transaction_Date
FROM sales_staging
WHERE Transaction_Date IS NULL;

SELECT Item, Price_Per_Unit
FROM sales_staging
WHERE Item = 'Coffee' AND Price_Per_Unit != 2;

-- CHECKING IF THE RECORDED PRICE IS CORRECT
SELECT
Transaction_ID, Item, Price_Per_Unit AS Price_On_Transaction,
CASE
	WHEN Item = 'Coffee' THEN 2
    WHEN Item = 'Tea' THEN 1.5
    WHEN Item = 'Sandwich' THEN 4
    WHEN Item = 'Salad' THEN 5
    WHEN Item = 'Cake' THEN 3
    WHEN Item = 'Cookie' THEN 1
    WHEN Item = 'Smoothie' THEN 4
    WHEN Item = 'Juice' THEN 3
END AS Expected_Price,
CASE
	WHEN Price_Per_Unit =
		CASE
			WHEN Item = 'Coffee' THEN 2
			WHEN Item = 'Tea' THEN 1.5
			WHEN Item = 'Sandwich' THEN 4
			WHEN Item = 'Salad' THEN 5
			WHEN Item = 'Cake' THEN 3
			WHEN Item = 'Cookie' THEN 1
			WHEN Item = 'Smoothie' THEN 4
			WHEN Item = 'Juice' THEN 3
		END
	THEN 'CORRECT'
    ELSE 'INCORRECT'
END AS Price_Check
FROM sales_staging;

WITH Price_Checker AS (
SELECT
Transaction_ID, Item, Price_Per_Unit AS Price_On_Transaction,
	CASE
		WHEN Item = 'Coffee' THEN 2
		WHEN Item = 'Tea' THEN 1.5
		WHEN Item = 'Sandwich' THEN 4
		WHEN Item = 'Salad' THEN 5
		WHEN Item = 'Cake' THEN 3
		WHEN Item = 'Cookie' THEN 1
		WHEN Item = 'Smoothie' THEN 4
		WHEN Item = 'Juice' THEN 3
	END AS Expected_Price,
	CASE
		WHEN Price_Per_Unit =
			CASE
				WHEN Item = 'Coffee' THEN 2
				WHEN Item = 'Tea' THEN 1.5
				WHEN Item = 'Sandwich' THEN 4
				WHEN Item = 'Salad' THEN 5
				WHEN Item = 'Cake' THEN 3
				WHEN Item = 'Cookie' THEN 1
				WHEN Item = 'Smoothie' THEN 4
				WHEN Item = 'Juice' THEN 3
			END
		THEN 'CORRECT'
		ELSE 'INCORRECT'
	END AS Price_Check
FROM sales_staging)
SELECT COUNT(Price_Check) AS INCORRECT_COUNT
FROM Price_Checker
WHERE Price_Check = 'INCORRECT'
AND Item != 'NaN';

UPDATE sales_staging
SET Transaction_Date = STR_TO_DATE(Transaction_Date, '%Y-%m-%d');

ALTER TABLE sales_staging
MODIFY COLUMN Transaction_Date DATE;