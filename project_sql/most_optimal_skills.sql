
/*
===============================================================
  File    : optimal_skills.sql
  Author  : Donghwan (Dylan) Lee
  Project : Data Job Market Analysis for College Students
===============================================================

  Question: What are the most optimal skills to learn for an
            entry-level Data Analyst?
            (high demand + high salary = best ROI for students)

  Approach:
    - Filters for entry-level, associate, and junior roles only
    - Combines demand count AND salary data in one query
    - Adds a verdict column to categorize each skill so students
      know exactly where to focus their learning effort
    - Removes statistically insignificant skills (demand > 10)

  Why?
    A skill that pays well but rarely appears in job postings is
    not worth prioritizing. This query finds the sweet spot --
    skills that are both common enough to get you hired AND
    pay well enough to be worth learning.

===============================================================
*/
WITH skills_demand AS (
  SELECT
    skills_dim.skill_id,
	  skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count
  FROM
    job_postings_fact
	  INNER JOIN
	    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
	  INNER JOIN
	    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
  WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
	  AND job_postings_fact.salary_year_avg IS NOT NULL
    AND job_postings_fact.job_work_from_home = True
  GROUP BY
    skills_dim.skill_id
),
-- Skills with high average salaries for Data Analyst roles
-- Use Query #4 (but modified)
average_salary AS (
  SELECT
    skills_job_dim.skill_id,
    AVG(job_postings_fact.salary_year_avg) AS avg_salary
  FROM
    job_postings_fact
	INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
	  -- There's no INNER JOIN to skills_dim because we got rid of the skills_dim.name 
  WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
	AND job_postings_fact.salary_year_avg IS NOT NULL
    AND job_postings_fact.job_work_from_home = True
  GROUP BY
    skills_job_dim.skill_id
)
-- Returns top 25 entry-level Data Analyst skills ranked by
-- demand and salary, with a student-friendly verdict label
-- that categorizes each skill as Must-Learn, High Value,
-- Advanced, or Nice to Have
SELECT
    skills_dim.skill_id,
    skills_dim.skills                               AS skill,
    skills_dim.type                                 AS skill_category,
    COUNT(skills_job_dim.job_id)                    AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0)      AS avg_salary,
    ROUND(MIN(job_postings_fact.salary_year_avg), 0)      AS min_salary,
    ROUND(MAX(job_postings_fact.salary_year_avg), 0)      AS max_salary,

    CASE
        WHEN COUNT(skills_job_dim.job_id) >= 100 AND AVG(job_postings_fact.salary_year_avg) >= 70000
            THEN 'Must-Learn'
        WHEN COUNT(skills_job_dim.job_id) >= 50 AND AVG(job_postings_fact.salary_year_avg) >= 80000
            THEN 'High Value'
        WHEN AVG(job_postings_fact.salary_year_avg) >= 90000
            THEN 'Advanced / Specialization'
        ELSE 'Nice to Have'
    END                                             AS verdict

FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id    = skills_job_dim.job_id
    INNER JOIN skills_dim     ON skills_job_dim.skill_id     = skills_dim.skill_id
WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
    AND job_postings_fact.salary_year_avg IS NOT NULL
    AND (
        job_postings_fact.job_title ILIKE '%entry%'
        OR job_postings_fact.job_title ILIKE '%associate%'
        OR job_postings_fact.job_title ILIKE '%junior%'
    )
GROUP BY
    skills_dim.skill_id,
    skills_dim.skills,
    skills_dim.type
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    demand_count DESC,
    avg_salary   DESC
LIMIT 25;