-- Exploratory Data Analysis

SELECT * FROM layoffs_staging_1;

SELECT MAX(total_laid_off)
FROM layoffs_staging_1; -- A maximum of 12000 layoffs were seen in a particular day in a particular company

 SELECT company, `date`, total_laid_off
 FROM layoffs_staging_1
 WHERE total_laid_off = (SELECT MAX(total_laid_off)
						FROM layoffs_staging_1); -- Google is the company that has laidoff the maximum number of employees in a single day.
                        
SELECT MAX(percentage_laid_off)
FROM layoffs_staging_1;

SELECT company, `date`, percentage_laid_off
FROM layoffs_staging_1 
WHERE percentage_laid_off = (SELECT MAX(percentage_laid_off)
							FROM layoffs_staging_1)
OR company LIKE 'Google'; -- There are multiple companies that laidoff 1% of their total employee strength. Which is the highest.  
-- But Google is not among them. 

SELECT company, `date`, percentage_laid_off, total_laid_off
FROM layoffs_staging_1 
WHERE percentage_laid_off = (SELECT MAX(percentage_laid_off)
							FROM layoffs_staging_1)
ORDER BY total_laid_off DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging_1
GROUP BY company
ORDER BY 2 DESC; -- Amazon laid off the highest number of the employees during this period, foloowed by Google and Meta. 

SELECT MIN(`date`), MAX(`date`), SUM(total_laid_off)
FROM layoffs_staging_1;

-- Over 0.38 million layoffs happened during the period given in the dataset(3 years)

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_1
GROUP BY 1
ORDER BY 2 DESC; -- Consumer industry was the worst hit during this period followed by reatil. 

SELECT country, SUM(total_laid_off)
FROM layoffs_staging_1
GROUP BY 1
ORDER BY 2 DESC; -- USA witnessed the highest number of layoffs followed by India and Netherlands. 

SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging_1
GROUP BY 1
ORDER BY 2 DESC; -- Highest number of layoffs were seen on 4th Jan 2023. 

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_1
GROUP BY 1 
ORDER BY 2 DESC; -- Highest number of layoffs from 2020 to 2023 were seen in the year 2022. 

SELECT  SUBSTR(`date`, 1, 7) AS 'Months', 
SUM(total_Laid_off)
FROM layoffs_staging_1
WHERE SUBSTR(`date`, 1, 7) IS NOT NULL
GROUP BY 1
ORDER BY 1; -- Month wise layoffs from 2020/03 to 2023/03

SELECT  SUBSTR(`date`, 1, 7) AS 'Months', 
SUM(total_Laid_off)
FROM layoffs_staging_1
WHERE SUBSTR(`date`, 1, 7) IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC; -- Highest number of layoffs in Jan 2023. 

SELECT sample_table.Months, sample_table.total_layoffs,
SUM(sample_table.total_layoffs) OVER(ORDER BY sample_table.Months) AS rolling_sum
FROM (
	SELECT  SUBSTR(`date`, 1, 7) AS Months, 
	SUM(total_Laid_off) AS total_layoffs
	FROM layoffs_staging_1
	WHERE SUBSTR(`date`, 1, 7) IS NOT NULL
	GROUP BY 1
	ORDER BY 1
) AS sample_table; -- Rolling sum of total layoffs w.r.t months 
-- Rows with NULL date have not been taken into consideration. 


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_1
GROUP BY 1
ORDER BY 2 DESC; -- Companies at the Post-IPO stage witnessed maximum number of layoffs.


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_1
GROUP BY 1, 2
ORDER BY 3 DESC; 

WITH company_year_layoffs (company, years, total_laid_off) AS
(	
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging_1
	GROUP BY 1, 2
    ORDER BY 3 DESC
)
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year_layoffs
WHERE total_laid_off IS NOT NULL AND years IS NOT NULL;

-- Ranking of companies based on their layoffs year wise.

WITH company_year_layoffs (company, years, total_laid_off) AS
(	
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging_1
	GROUP BY 1, 2
    ORDER BY 3 DESC
)
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS year_wise_ranking
FROM company_year_layoffs
WHERE total_laid_off IS NOT NULL AND years IS NOT NULL
GROUP BY years;
-- Highest layoffs each year from 2020 to 2023. 
-- 2020 - Uber was the highest laying off company with 7525 layoffs . 
-- 2021 - Bytedance was the highest laying off company with 3600 layoffs. 
-- 2022 - Meta was the highest laying off comapny with 11000 layoffs.
-- 2023 - Google was the highest laying off company with 12000 layoffs. 


WITH company_year_layoffs (company, years, total_laid_off) AS
(	
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging_1
	GROUP BY 1, 2
), company_year_ranking AS
(SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year_layoffs
WHERE total_laid_off IS NOT NULL AND years IS NOT NULL
)
SELECT *
FROM company_year_ranking
WHERE ranking <= 5; -- Top five companies as per layoffs each year. 
 


  

 
 
 

 

 