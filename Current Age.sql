
--ISSUE:
--The HR department requests a report on the percentage of employees within specific age intervals to aid in understanding the company's generational workforce distribution.

--You have been provided with a database containing an employees table with the following schema:

--employee_id (integer): A unique identifier for each employee.
--date_of_birth (date): The birth date of the employee
--Your task is to write an SQL query that calculates the current age of each employee, categorizes these ages into intervals (18-20, 26-40, and above 40 years), and returns the percentage of employees within each interval. Round all percentages to two decimal places.

--Requirements:

--Compute the current age of each employee from their date_of_birth based on the current date.
--Use the calculated ages to categorize employees into the following age brackets: 18-20 (inclusive), 26-40, and above 40. Ensure the age ranges include the entire span (e.g., up to but not including 21 years for the 18-20 bracket).
--Calculate the percentage of the total workforce that falls within each age bracket, rounding the result to two decimal places. For age brackets with no employees, the query should display 0.0.
--The query should output a table with two columns: age_interval and percent (of numeric datatype). The age_interval should be a string representation of the age range ('18-20', '26-40', '>40'), and percent should be the corresponding percentage of total employees, rounded to two decimal places.




--My Solution:

WITH age_range AS (
    SELECT '18-20' AS age_interval
    UNION
    SELECT '26-40' AS age_interval
    UNION
    SELECT '>40' AS age_interval
)

SELECT 
    age_range.age_interval, 
    CASE
        WHEN needed_info.percent is null then 0.0
        ELSE needed_info.percent
    END AS percent
FROM age_range
LEFT OUTER JOIN (
    SELECT
      CASE
          WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 18 AND 20 THEN '18-20'
          WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 26 AND 40 THEN '26-40'
          WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) > 40 THEN '>40'
          ELSE 'Unknown'
      END AS age_interval,
      ROUND((COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM employees), 0), 2) AS percent
    FROM employees
    GROUP BY age_interval
    ORDER BY age_interval
) AS needed_info ON age_range.age_interval = needed_info.age_interval;




--Study Solution:
--Done By: monadius

with ages as (
  select extract(year from age(date_of_birth)) as age from employees
)
(select '18-20' as age_interval, round(100 * (select count(*) from ages where age between 18 and 20) / (select count(*) from ages), 2) as percent
union
select '26-40' as age_interval, round(100 * (select count(*) from ages where age between 26 and 40) / (select count(*) from ages), 2) as percent
union
select '>40' as age_interval, round(100 * (select count(*) from ages where age > 40) / (select count(*) from ages), 2) as percent)
order by 1
