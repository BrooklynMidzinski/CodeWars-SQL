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