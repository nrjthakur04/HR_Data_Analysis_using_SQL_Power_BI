-- Create Database
create database hr;

-- Use the newly create database so that the chnages will be made i this database only.
use hr;

-- Create the structure of the table as per your original data
create table hr_data(
id varchar(15) not null,
first_name varchar(100),	
last_name varchar(100),	
birthdate varchar(100),
gender	varchar(100),
race varchar(100),	
department varchar(100),	
jobtitle varchar(100),	
location varchar(100),	
hire_date varchar(100), 	
termdate varchar(100),	
location_city varchar(100),	
location_state varchar(100)
);

-- To See the table structure
describe hr_data;

-- To see the contents of the table
select * from hr_data; 

-- Change the datatype of termdate column to date/ Its better to keep the same and create new column new_termdate
-- Step 1: Create a new column new_termdate
ALTER TABLE hr_data ADD COLUMN new_termdate DATE;

-- Step 2: Update the new column with valid date values
UPDATE hr_data
SET new_termdate = STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')
WHERE termdate != '' AND STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC') IS NOT NULL;

select new_termdate from hr_data;

-- We have a birthdate column where date data is given in format 
-- '9/14/1982' and '04-11-1994' for different rows. We'will fix this too and create a new column "age" and extract year

UPDATE hr_data
SET birthdate = CASE
    WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;
UPDATE hr_data
SET hire_date = CASE
    WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

select * from hr_data;

alter table hr_data add column age int;

update hr_data
set age=timestampdiff(year, birthdate, curdate())
where birthdate is not null;

select * from hr_data;

-- QUESTIONS TO ANSWER FROM THE DATA

-- 1) What's the age distribution in the company?
-- age disttribution
select 
max(age) as senior,
min(age) as young
from hr_data;

-- Making age_group based on ages
select age_group, 
count(*) as count
from(
select case
	 when age>=21 and age<=30 then '21 to 30'
	 when age>=31 and age<=40 then '31 to 40'
	 when age>=41 and age<=50 then '41 to 50'
else '50+'
end as age_group
from hr_data
where new_termdate is null) as subquery 
group by age_group
order by age_group;

-- Age group by Gender

select age_group,gender,
count(*) as count
from(
select case
	 when age>=21 and age<=30 then '21 to 30'
	 when age>=31 and age<=40 then '31 to 40'
	 when age>=41 and age<=50 then '41 to 50'
else '50+'
end as age_group,
gender
from hr_data
where new_termdate is null) as subquery 
group by age_group,gender
order by age_group,gender;

-- 2) What's the gender breakdown in the company?

select gender,
count(gender) as count
from hr_data
where new_termdate is null
group by gender 
order by gender asc;

-- 3) How does gender vary across department and job titles?

select department,gender,
count(gender) as count
from hr_data
where new_termdate is null
group by department,gender
order by department,gender asc;

select department,jobtitle,gender,
count(gender) as count
from hr_data
where new_termdate is null
group by department,jobtitle,gender
order by department,jobtitle,gender asc;

-- 4) What is the race distribution in the company?

select race,
count(*) as count 
from hr_data
where new_termdate is null
group by race
order by count desc ;

-- 5) What is the average length of employment in the company?

select avg(timestampdiff(year,hire_date,new_termdate)) as tenure
from hr_data
where new_termdate is not null and new_termdate <=curdate();

select * from hr_data;

-- 6) Which department has the highest turnover rate?
-- get total count
-- get terminated count
-- terminated cont/total count

select department,total_count,terminated_count,
round((terminated_count/total_count)*100,2) as turnover_rate
from(
select department,
count(*) as total_count,
sum(case 
	when new_termdate is not null and new_termdate <=curdate() then 1 else 0
    end) as terminated_count
from hr_data
group by department) as subquery
order by turnover_rate desc;

-- 7) What is the tenure distribution for each department?

select department,
avg(timestampdiff(year,hire_date,new_termdate)) as tenure
from hr_data
where new_termdate is not null and new_termdate <=curdate()
group by department
order by tenure desc;

-- How many employees work remotely for each department?

select location,
count(*) as count
from hr_data
where new_termdate is null
group by location;

select location,department,
count(*) as count
from hr_data
where new_termdate is null
group by location,department
order by location;

-- 9) What is the distribution of employees across different satates?

select location_state,
count(*) as count
from hr_data
where new_termdate is null
group by location_state
order by count desc;

-- 10) How are job titles distributed in the  company?

select jobtitle,
count(*) as count
from hr_data
where new_termdate is null
group by jobtitle
order by count desc;

-- 11) How have employees hire counts varies over time? 
-- calculare hires
-- calculate terminations
-- (hires-terminations).hires percent hire change

select hire_year,
hires,terminations,
hires-terminations as net_change,
round((hires-terminations)/hires*100,2) as percent_hire_change
from(
select year(hire_date) as hire_year,
count(*) as hires,
sum(case 
		when new_termdate is not null and new_termdate<=curdate() then 1 else 0
        end) as terminations
from hr_data
group by year(hire_date)) as subquery;

