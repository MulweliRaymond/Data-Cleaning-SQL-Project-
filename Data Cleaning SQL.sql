SELECT *
FROM layoffs;
-- creating a copy of a row data
CREATE TABLE layoffs_staging
Like layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;
-- Trying to remove duplicates
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location, industry, total_laid_off,percentage_laid_off,'date',country,stage) as row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location, industry, total_laid_off,percentage_laid_off,'date',country,stage,funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num>1;

CREATE TABLE layoff_staging2
LIKE layoffs_staging;

ALTER TABLE layoff_staging2
ADD COLUMN row_num INT;

INSERT layoff_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location, industry, total_laid_off,percentage_laid_off,'date',country,stage,funds_raised_millions) as row_num
FROM layoffs_staging
;

SELECT *
FROM  layoff_staging2;

INSERT INTO layoff_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location, industry, total_laid_off,percentage_laid_off,'date',country,stage,funds_raised_millions) as row_num
FROM layoffs_staging
;
DELETE
FROM layoff_staging2
WHERE row_num>1;

SELECT *
FROM layoff_staging2;

-- Standardising data

SELECT company, TRIM(company)
FROM layoff_staging2;

UPDATE layoff_staging2
SET company=TRIM(company);

SELECT *
FROM layoff_staging2;

SELECT DISTINCT(industry)
FROM layoff_staging2
Order by 1;

UPDATE layoff_staging2
SET industry='Crypto'
WHERE industry Like 'Crypto%';

SELECT *
FROM layoff_staging2;

SELECT DISTINCT location
FROM layoff_staging2;

SELECT DISTINCT country
FROM layoff_staging2
Order by 1;

UPDATE layoff_staging2
SET country= 'United States'
WHERE country LIKE 'United States%';

SELECT *
FROM layoff_staging2
WHERE country LIKE 'United States%';

SELECT `date`, str_to_date(`date`,'%m/%d/%Y')
FROM layoff_staging2;

UPDATE layoff_staging2
SET `date`=STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT *
FROM layoff_staging2;

ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;

-- NULL AND BLANK VALUES
SELECT *
FROM layoff_staging2;

SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE 
FROM layoff_staging2
WHERE total_laid_off is NULL AND percentage_laid_off is NULL;

ALTER TABLE layoff_staging2
DROP COLUMN row_num;

SELECT *
FROM layoff_staging2;

SELECT *
FROM layoff_staging2
WHERE industry is NULL OR industry='';

UPDATE layoff_staging2
SET industry=null
WHERE industry='';

SELECT *
FROM layoff_staging2
WHERE industry is null;

DELETE 
FROM layoff_staging2
WHERE industry IS NULL;

UPDATE layoff_staging2 t1
JOIN layoff_staging2  t2
	ON t1.company=t2.company AND t1.location=t2.location
SET t1.industry= t2.industry
where t1.industry is null and t2.industry is not null;


SELECT *
FROM layoff_staging2;