-- Data Cleaning Project by SQL
-- ============================ 
CREATE DATABASE eda_project;
USE eda_project;
SHOW TABLES;
SELECT * FROM layoffs;

-- Steps taken for Data Cleaning
-- ============================== 

-- Step 1 :- Removal of duplicates if there are any.
-- Step 2 :- Standardization of the data.
-- Step 3 :- Dealing with null and blank values.
-- Step 4 :- Removal any rows.

-- First we create a table that is a copy of the imported table. 
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

-- Inserting all the data from imported table to the newly create duplicate table. 
INSERT INTO layoffs_staging 
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-- 1)Finding the duplicates 
-- a) Writing the condition for duplicates.

SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS row_num
FROM layoffs_staging;

-- b) Checking if there are any duplicates. 

WITH duplicate_table AS 
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`,stage, country, funds_raised_millions)
AS row_num
FROM layoffs_staging
)
SELECT * FROM duplicate_table
WHERE row_num > 1;

-- c) Now creating a separate table where the delete operation will be performed. 

CREATE TABLE layoffs_staging_1
LIKE layoffs_staging;

SELECT * FROM layoffs_staging_1;

ALTER TABLE layoffs_staging_1
ADD row_num INT;

-- d) Inserting the data in the new table.

INSERT INTO layoffs_staging_1
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
AS row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging_1;

-- e) Performing the delete operation. 

DELETE FROM layoffs_staging_1
WHERE row_num > 1;

SELECT * FROM layoffs_staging_1
WHERE row_num > 1;

-- f) Deletion of the duplicate rows is successfull. 

-- 2) Standardizing the data.
-- a) Performing functions on the company column.  
  
SELECT company FROM layoffs_staging_1;
-- As it can be noticed that there are irregular spacing in the company name. 
-- Performing TRIM() operation on the company names. 

SELECT company, TRIM(company)
FROM layoffs_staging_1;  

UPDATE layoffs_staging_1
SET company = TRIM(company);

SELECT company FROM layoffs_staging_1;
-- Company column has been standardized. 

-- b) Performing functions on the Industries column. 

SELECT industry FROM layoffs_staging_1
GROUP BY industry; -- Checking all the availibale industries. 

-- There is a discrepancy in names of crypto industry. Same industry has been named different in different columns. 
-- Getting the industry column for each of these rows same.  

SELECT * FROM layoffs_staging_1 
WHERE industry = 'Crypto';

SELECT COUNT(*) FROM layoffs_staging_1
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging_1
SET industry = 'Crypto'
WHERE industry = 'Crypto Currency' OR industry = 'CryptoCurrency';
-- All the rows with distinct name indicating same industry i.r crypto has now been updated. 

SELECT DISTINCT industry
FROM layoffs_staging_1;

-- c) Checking the location column 

SELECT DISTINCT location
FROM layoffs_staging_1
ORDER BY 1; 

SELECT DISTINCT country
FROM layoffs_staging_1
ORDER BY 1;

-- There is a discrepancy with United States in the country column. 

SELECT * FROM layoffs_staging_1
WHERE country LIKE '%United States%';

UPDATE layoffs_staging_1
SET country = 'United States'
WHERE country = 'United States.'; -- Rows have been updated. 

-- Now dealing with the dates column

SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y') AS new_date
FROM layoffs_staging_1;  

-- We are to update the already existing date column to the new_date column format and datatype 

UPDATE layoffs_staging_1
SET `date` =  STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date` FROM layoffs_staging_1; -- Now the date column has been updated. 

ALTER TABLE layoffs_staging_1
MODIFY COLUMN `date` DATE; -- Changing the data type of the date column from string to date

-- 3) Dealing with the NULL or blank values

SELECT * FROM layoffs_staging_1
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging_1
WHERE industry IS NULL 
OR industry = '';  -- With this we should be able to find those rows where a company doesn't have a indystry. 
-- We can use the company name to find if there are multiple rows associated to it. And if their industry column is populated
-- we should be able to populate the industry column for those similar rows where the industry column is a Null value. 

SELECT * FROM layoffs_staging_1
WHERE company = 'Airbnb';    -- There is a row associated to Airbnb that has travel as its industry. Updating other rows with the same value. 

SELECT * 
FROM layoffs_staging_1 AS t1
JOIN layoffs_staging_1 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging_1
SET industry = NULL 
WHERE industry = '';

UPDATE layoffs_staging_1 AS t1
JOIN layoffs_staging_1 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

DELETE FROM layoffs_staging_1
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging_1
DROP COLUMN row_num;

SELECT COUNT(*) FROM layoffs_staging_1;

SELECT * FROM layoffs_staging_1;





 



 




 





 












  

