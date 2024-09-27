# HR DATA ANALYSIS - MYSQL / POWER BI
This project explores key HR metrics, including age, gender, race distribution, turnover rates, and tenure, to gain insights into employee demographics, retention, and diversity.
In this project I've used MySQL and Power BI to uncover valuable HR insights. It features interactive dashboards displaying key metrics like employee turnover, diversity, recruitment effectiveness, and performance evaluations. These insights help HR professionals make informed decisions and plan strategically.

## Source Data:
HR DATA: The primary dataset used for this analysis is the "HR_data.csv" file, containing information about each employees who are working and has left the company. The data contains 22214 rows from year 2000 to 2020. The is attached in this repo as HR_data.csv.

## Data Cleaning & Analysis:
This was done on MYSQL Workbench involving
- Data loading & inspection
- Handling missing values
- Data cleaning and analysis

## Data Visualization:
Power BI Desktop 

![powerbi-1](https://github.com/kahethu/hr_data/assets/27964625/0d485a7e-3ddf-4a20-b158-b60fd8226f55)

![powerbi-2](https://github.com/kahethu/hr_data/assets/27964625/6fc20ddb-fb5e-4349-bee3-7fe714737d60)



## Exploratory Data Analysis
### Questions:
1)	What's the age distribution in the company?
2)	What's the gender breakdown in the company?
3)	How does gender vary across departments and job titles?
4)	What's the race distribution in the company?
5)	What's the average length of employment in the company?
6)	Which department has the highest turnover rate?
7)	What is the tenure distribution for each department?
8)	How many employees work remotely for each department?
9)	What's the distribution of employees across different states?
10)	How are job titles distributed in the company?
11)	How have employee hire counts varied over time?


### Findings:
1)	There are more male employees than female or non-conforming employees.(M-11288,F-10321,NC-10321)-Total
2)	The genders are fairly evenly distributed across departments. There are slightly more male employees overall.(M-8455,F-9328,NC-502)
3)	Employees 21-30 years old are the fewest in the company. Most employees are 31-50 years old. Surprisingly, the age group 50+ have the most employees in the company.
4)	Caucasian employees are the majority in the company, followed by mixed race, black, Asian, Hispanic, and native Americans.
5)	The average length of employment is 7.43 years.
6)	Auditing has the highest turnover rate, followed by Legal, Research & Development and Training. Business Development & Marketing have the lowest turnover rates.
7)	Employees tend to stay with the company for 6-8 years. Tenure is quite evenly distributed across departments.
8)	About 25% of employees work remotely.
9)	Most employees are in Ohio (14,788) followed distantly by Pennsylvania (930) and Illinois (730), Indiana (572), Michigan (569), Kentucky (375) and Wisconsin (321).
10)	There are 182 job titles in the company, with Research Assistant II taking most of the employees (634) and Assistant Professor, Marketing Manager, Office Assistant IV, Associate Professor and VP of Training and Development taking the just 1 employee each.
11)	Employee hire counts have increased over the years

### MYSQL Quries

### 1) Create Database
``` SQL
CREATE DATABASE hr;
```
### 1) Create Table hr_data
``` SQL
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
location_state varchar(100));
```
### 3) Import Data to SQL Server
- On left pane Right-click on hr(database) > Table Data Import Wizard > Browse Path
- Use import wizard to import HR_data.csv to hr_data table.
- Verify that the import worked:

``` SQL
use hr;
```
``` SQL
SELECT *
FROM hr_data;
```

### 3) DATA CLEANING
The termdate was imported as varchar(100). This column contains termination dates, hence it needs to be converted to the date format.

####	Update date/time to date
![format-termdate-1](https://github.com/kahethu/data/assets/27964625/463e86e0-8b1a-47c8-943e-f125bad98706)

 Update termdate date/time to date
- convert dates to yyyy-MM-dd
- create new column new_termdate
- copy converted time values from termdate to new_termdate

- create new column new_termdate
- We found that data in the column termdate is inconsistent, like somewhere in date time,irregular format, also dtype is varchar(). So we'll change the datatype of termdate column to date and only keep date/ Its better to keep the same and create new column new_termdate

``` SQL
ALTER TABLE hr_data
ADD COLUMN new_termdate DATE;
```

- Update the new column with valid date values to new_termdate

``` SQL
UPDATE hr_data
SET new_termdate = STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')
WHERE termdate != '' AND STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC') IS NOT NULL;
```
- check results

``` SQL
SELECT new_termdate
FROM hr_data;
```

#### create new column "age"

- We have a birthdate and hire_date column where date data is given in format '9/14/1982' and '04-11-1994' for different rows. We'will fix this too and create a new column "age" and extract year to make use of this data solving upcomming queries.

``` UPDATE hr_data
SET birthdate = CASE
    WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;
```
``` UPDATE hr_data
SET hire_date = CASE
    WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;
```
``` SQL
ALTER TABLE hr_data
ADD COLUMN age int;
```

#### populate new column with age
``` SQL
UPDATE hr_data
SET age = TIMESTAMPDIFF(year, birthdate, CURDATE())
where birthdate IS NOT NULL;
```

## QUESTIONS TO ANSWER FROM THE DATA

#### 1) What's the age distribution in the company?

- age distribution

``` SQL
SELECT
 MIN(age) AS youngest,
 MAX(age) AS senior
FROM hr_data;
```

- Making age_group based on ages

``` SQL
SELECT age_group,
count(*) AS count
FROM
(SELECT 
 CASE
  WHEN age >= 21 AND age <= 30 THEN '21 to 30'
  WHEN age >= 31 AND age <= 40 THEN '31 to 40'
  WHEN age >= 41 AND age <= 50 THEN '41 to 50'
  ELSE '50+'
  END AS age_group
 FROM hr_data
 WHERE new_termdate IS NULL
 ) AS subquery
GROUP BY age_group
ORDER BY age_group;
```

- Age group by gender

``` SQL
SELECT age_group,
gender,
count(*) AS count
FROM
(SELECT 
 CASE
  WHEN age >= 21 AND age <= 30 THEN '21 to 30'
  WHEN age >= 31 AND age <= 40 THEN '31 to 40'
  WHEN age >= 41 AND age <= 50 THEN '41 to 50'
  ELSE '50+'
  END AS age_group,
  gender
 FROM hr_data
 WHERE new_termdate IS NULL
 ) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;
```
#### 2) What's the gender breakdown in the company?

``` SQL
SELECT
 gender,
 COUNT(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;
```

#### 3) How does gender vary across departments and job titles?
- departments
  
``` SQL
SELECT 
department,
gender,
count(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department, gender,
ORDER BY department, gender ASC;
```
- job titles

``` SQL
SELECT 
department, jobtitle,
gender,
count(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender ASC;
```

#### 4) What's the race distribution in the company?

``` SQL
SELECT
race,
count(*) AS count
FROM
hr_data
WHERE new_termdate IS NULL 
GROUP BY race
ORDER BY count DESC;
```

#### 5) What's the average length of employment in the company?

``` SQL
SELECT 
AVG(TIMESTAMPDIFF(year, hire_date, new_termdate)) AS tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= CURDATE();
```

#### 6) Which department has the highest turnover rate?
- get total count
- get terminated count
- terminated count/total count

``` SQL
SELECT
 department,
 total_count,
 terminated_count,
 (round((((terminated_count/total_count)*100,2) as turnover_rate
 FROM
	(SELECT 
	 department,
	 count(*) AS total_count,
	 SUM(CASE
		WHEN new_termdate IS NOT NULL AND new_termdate <= CURDATE() THEN 1 ELSE 0
		END
		) AS terminated_count
	FROM hr_data
	GROUP BY department
	) AS subquery
ORDER BY turnover_rate DESC
LIMIT 1;
```

#### 7) What is the tenure distribution for each department?

``` SQL
SELECT 
    department,
    AVG(TIMESTAMPDIFF(year, hire_date, new_termdate)) AS tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= CURDATE()
GROUP BY department
ORDER BY tenure DESC;
```


#### 8) How many employees work remotely for each department?

``` SQL
SELECT
 location,department
 count(*) as count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location,department
ORDER BY location;
```

#### 9) What's the distribution of employees across different states?

``` SQL
SELECT 
 location_state,
 count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;
```

#### 10) How are job titles distributed in the company?

``` SQL
SELECT 
 jobtitle,
 count(*) AS count
 FROM hr_data
 WHERE new_termdate IS NULL
 GROUP BY jobtitle
 ORDER BY count DESC;
```

#### 11) How have employee hire counts varied over time?
- calculate hires
- calculate terminations
- (hires-terminations)/hires percent hire change

``` SQL
SELECT
 hire_year,
 hires,terminations,
 (hires - terminations) AS net_change,
 round((hires-terminations)/hires*100,2) AS percent_hire_change
 FROM
	(SELECT 
	 YEAR(hire_date) AS hire_year,
	 count(*) AS hires,
	 SUM(CASE
			WHEN new_termdate is not null and new_termdate <= CURDATE() THEN 1 ELSE 0
			END
			) AS terminations
	FROM hr_data
	GROUP BY YEAR(hire_date)
	) AS subquery
ORDER BY percent_hire_change ASC;
```
## Thank you for visiting.
