/*
===============================================================
  File    : different_level_job_skills.sql
  Author  : Donghwan (Dylan) Lee
  Project : Data Job Market Analysis for College Students
===============================================================

  Question: What skills should college students prioritize to
            maximize both salary AND employability?

  Approach:
    - Filters for entry-level and associate Data Analyst roles only
    - Calculates average, min, and max salary per skill per job title
      so students can see the realistic salary range, not just an average
    - Includes skill category to help students group and prioritize
      what to learn (programming vs. tools vs. cloud, etc.)
    - Sets a minimum demand threshold of 10 to exclude skills that
      appear too rarely to be statistically meaningful

  Why?
    High salary alone is misleading. A skill with a $120K average
    based on 2 job postings is not worth the same investment as a
    skill with an $85K average across 200 postings. This query
    surfaces skills that are both well-compensated AND consistently
    requested by employers hiring entry-level analysts.

===============================================================
*/

-- Returns entry-level, associate, junior Data Analyst skills ranked
-- by average salary, filtered to skills appearing in 10+ postings
SELECT
    job_postings_fact.job_title                             AS job_title,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0)        AS avg_salary,
    ROUND(MIN(job_postings_fact.salary_year_avg), 0)        AS min_salary,
    ROUND(MAX(job_postings_fact.salary_year_avg), 0)        AS max_salary,
    COUNT(DISTINCT job_postings_fact.job_id)                AS job_demand,
    STRING_AGG(DISTINCT skills_dim.skills, ' | '
        ORDER BY skills_dim.skills)                         AS required_skills
FROM
    job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id  = skills_job_dim.job_id
    INNER JOIN skills_dim     ON skills_job_dim.skill_id   = skills_dim.skill_id
WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
    AND job_postings_fact.job_country = 'United States'
    AND job_postings_fact.salary_year_avg IS NOT NULL
    AND (
        job_postings_fact.job_title ILIKE '%entry%'
        OR job_postings_fact.job_title ILIKE '%associate%'
        OR job_postings_fact.job_title ILIKE '%junior%'
    )
GROUP BY
    job_postings_fact.job_title
HAVING
    COUNT(DISTINCT job_postings_fact.job_id) >= 10
ORDER BY
    avg_salary DESC;