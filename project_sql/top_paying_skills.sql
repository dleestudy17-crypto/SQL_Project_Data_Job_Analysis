/*
**Answer: What are the top skills based on salary?** 

- Look at the average salary associated with each skill for Data Analyst positions.
- Focuses on roles with specified salaries, regardless of location.
- Why? It reveals how different skills impact salary levels for Data Analysts and helps identify the most financially rewarding skills to acquire or improve.
*/
-- Calculates the average salary for job postings by individual skill 
SELECT
  skills_dim.skills AS skill, 
  ROUND(AVG(job_postings_fact.salary_year_avg),2) AS avg_salary
FROM
  job_postings_fact
	INNER JOIN
	  skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
	INNER JOIN
	  skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  job_postings_fact.job_title_short = 'Data Analyst' 
  AND job_postings_fact.salary_year_avg IS NOT NULL 
	-- AND job_work_from_home = True  -- optional to filter for remote jobs
GROUP BY
  skills_dim.skills 
ORDER BY
  avg_salary DESC; 

  -- Insights on Top Paying Data Analyst Skills

-- 1. Some extreme salaries (ex: SVN $400k, Solidity $179k) are likely outliers
--    caused by very small numbers of job postings.

-- 2. Many high-paying skills come from DevOps / infrastructure tools
--    (Terraform, Ansible, Puppet, VMware, Kafka), showing overlap with
--    data engineering responsibilities.

-- 3. Machine learning frameworks (PyTorch, TensorFlow, Keras, MXNet)
--    appear frequently, suggesting analysts with ML skills earn more.

-- 4. Big data technologies (Spark, PySpark, Hadoop, Databricks, Airflow)
--    are associated with higher salaries due to large-scale data processing.

-- 5. Cloud platforms (AWS, GCP, Azure, Snowflake, BigQuery, Redshift)
--    are strong salary drivers in modern analytics roles.

-- 6. Traditional analyst tools (SQL, Tableau, Power BI, Excel)
--    appear lower in salary rankings because they are baseline skills
--    and more common among candidates.

-- Key takeaway:
-- The highest paying "data analyst" roles increasingly require hybrid
-- skills across analytics, data engineering, machine learning, and cloud.