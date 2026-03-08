/* 
🟩 Problem 1
CASE Statements
Problem Statement
From the job_postings_fact table, categorize the salaries from job postings that are data analyst jobs, 
and that have yearly salary information. Put salary into 3 different categories:

If the salary_year_avg is greater than or equal to $100,000, then return ‘high salary’.
If the salary_year_avg is greater than or equal to $60,000 but less than $100,000, then return ‘Standard salary.’
If the salary_year_avg is below $60,000 return ‘Low salary’.
Also, order from the highest to the lowest salaries.

Hint
In SELECT retrieve these columns: job_id, job_title, salary_year_avg, and a new column for the salary category.

CASE Statement: Use to categorize salary_year_avg into 'High salary', 'Standard salary', or 'Low salary'.
If the salary is over $100,000, it's a High salary.
For salaries greater than or equal to $60,000,  assign Standard salary.
Any salary below $60,000 should be marked as Low salary.
FROM the job_postings_fact table.
WHERE statement:
Exclude records without a specified salary_year_avg.
Focus on job_title_short that exactly matches 'Data Analyst'.
Use ORDER BY to sort by salary_year_avg in descending order to start with the highest salaries first.
*/
SELECT *
FROM job_postings_fact

SELECT
  job_id,
  job_title,
  salary_year_avg,
  CASE 
    WHEN salary_year_avg >= 100000 THEN 'High salary'
    WHEN salary_year_avg >= 60000 THEN 'Standard salary'
    WHEN salary_year_avg < 60000 THEN 'Low salary'
  END AS salary_category
FROM 
	job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
    and job_title_short = 'Data Analyst'
ORDER BY
    salary_year_avg DESC;

/*
🟨 Problem 2
CASE Statements
Problem Statement
Count the number of unique companies that offer work from home (WFH) 
versus those requiring work to be on-site. Use the job_postings_fact table 
to count and compare the distinct companies based on their WFH policy (job_work_from_home).

Hint
Use COUNT with DISTINCT to ensure each company is only counted once, 
even if they have multiple job postings.
Use CASE WHEN to separate companies based on their WFH policy (job_work_from_home column).
*/

SELECT 
    COUNT(DISTINCT CASE WHEN job_work_from_home = TRUE THEN company_id END) AS wfh_companies,
    COUNT(DISTINCT CASE WHEN job_work_from_home = FALSE THEN company_id END) AS non_wfh_companies
FROM job_postings_fact;

-- Problem 3
SELECT 
    job_id,
    salary_year_avg,
    CASE
        WHEN job_title LIKE '%Senior%' THEN 'Senior'
        WHEN job_title LIKE '%Manager%' OR job_title LIKE '%Lead%' THEN 'Lead/Manager'
        WHEN job_title LIKE '%Junior%' OR job_title LIKE '%Entry%' THEN 'Junior/Entry'
        ELSE 'Not Specified'
    END AS experience_level,
    CASE
        WHEN job_work_from_home = TRUE THEN 'Yes'
        ELSE 'No'
    END AS remote_option
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_id;