-- Data Cleaning

select *
from layoffs;
-- DATA CLEANING
-- 1. remove duplicates
-- 2. standardize data
-- 3. Null values or blank values
-- 4. remove any columns

create table layoffs_staging
like layoffs; 

select * 
from layoffs_staging;

-- inserting the data in the new staging table
insert layoffs_staging
select *
from layoffs; 

-- Removing duplicates
-- Checking for duplicates in our table using row_number and partition
select * ,
row_number() 
over(partition by company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
from layoffs_staging;

-- Visualising only duplicates
with duplicate_cte as
(
select * ,
row_number() 
over(partition by company, location, 
industry, total_laid_off, percentage_laid_off, 'date', 
stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

-- Adding the row_num column to a new staging table to be able to remove the duplicates
insert into layoffs_staging2
select *,
row_number() 
over(partition by company, location, 
industry, total_laid_off, percentage_laid_off, 'date', 
stage, country, funds_raised_millions) as row_num
from layoffs_staging;

select *
from layoffs_staging2
where row_num >1;

delete
from layoffs_staging2
where row_num > 1;

-- Checking the result of the delete operation
select *
from layoffs_staging2;

-- standardizing data

select distinct(trim(company))
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

-- After reviewing the table, there are some cells where industry is Crypto Currency, however
-- it should be considered as Crypto. We need to remove the duplicate
select *
from layoffs_staging2
where industry like 'Crypto%'
;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct industry
from layoffs_staging2;

select distinct country
from layoffs_staging2
order by 1;

-- Here after checking some columns, we've found out that there are some cells with a dot 
-- after the name of the country. We also need to remove it. 
select *
from layoffs_staging2
where country like 'United States%';

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

-- Changing the date from string to date format
update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;

select *
from layoffs_staging2;

-- Nulls

select * 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null
;

select *
from layoffs_staging2
where industry is null or industry = '';

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location 
where (t1.industry is null or t1.industry = '')
and t2.industry is not null
;

update layoffs_staging2
set industry = null
where industry = '';

-- after setting the '' values to null we can remove all nulles where there is some data in another row
update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

-- remove 

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;


-- Exploratory Data Analysis

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2
;

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- total number of employees laid off by company
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- Period and number of people being laid off
select min(`date`), max(`date`), sum(total_laid_off)
from layoffs_staging2
;

-- Total by industry
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- Total by country
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- Layoffs by year
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

-- total layoffs by month
select substring(`date`,6,2) as `month`, sum(total_laid_off)
from layoffs_staging2
group by `month`
order by 1;

select substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;

-- Rolling total progression 
with rolling_total as
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`, total_off, sum(total_off) over(order by `month`) 
from rolling_total;

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

-- Ranking layoffs by year
with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
)
select *, dense_rank() over(partition by years order by total_laid_off desc)
as Ranking
from company_year
where years is not null
order by ranking asc;














