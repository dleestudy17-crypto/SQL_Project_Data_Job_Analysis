
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
    - Two CTEs build the broader U.S. market baseline across
      Data Analyst, Data Engineer, and Data Scientist roles:
        · skills_demand  → total market demand per skill
        · average_salary → market-wide average salary per skill
    - The final SELECT filters down to entry-level and intern
      Data Analyst postings only, then joins the CTEs to
      compare entry-level metrics against the broader market
    - A verdict column categorizes each skill so students know
      exactly where to focus their learning effort:
        · Must-Learn           → high demand + solid salary
        · High Value           → moderate demand + good salary
        · Advanced/Specialization → low demand but high salary
        · Nice to Have         → everything else
    - Removes statistically insignificant skills (demand > 10)
    - Returns top 25 skills ranked by entry-level demand
      then by entry-level average salary

  Key Columns:
    · entry_level_demand    → how often skill appears in
                              entry-level / intern postings
    · total_market_demand   → how often skill appears across
                              all three data roles in the U.S.
    · entry_level_avg_salary → average salary for entry-level
                              postings requiring this skill
    · market_avg_salary     → average salary across all three
                              data roles for this skill
    · salary_gap            → difference between entry-level
                              and market salary (negative means
                              entry-level pays below market)

  Why?
    A skill that pays well but rarely appears in job postings
    is not worth prioritizing. This query finds the sweet spot:
    skills that are common enough to get you hired AND pay well
    enough to be worth the learning investment.

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
    (
      job_postings_fact.job_title_short = 'Data Analyst'
    OR job_postings_fact.job_title_short = 'Data Engineer'
    OR job_postings_fact.job_title_short = 'Data Scientist'
    )
    AND job_country = 'United States'
	  AND job_postings_fact.salary_year_avg IS NOT NULL
  GROUP BY
    skills_dim.skill_id
),
average_salary AS (
  SELECT
    skills_job_dim.skill_id,
    AVG(job_postings_fact.salary_year_avg) AS avg_salary
  FROM
    job_postings_fact
	INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  WHERE
    ( 
      job_postings_fact.job_title_short = 'Data Analyst'
    OR job_postings_fact.job_title_short = 'Data Engineer'
    OR job_postings_fact.job_title_short = 'Data Scientist'
    )
    AND job_country = 'United States'
	  AND job_postings_fact.salary_year_avg IS NOT NULL
  GROUP BY
    skills_job_dim.skill_id
)

SELECT
    skills_dim.skills                                AS skill,
    COUNT(skills_job_dim.job_id)                     AS entry_level_demand,
    skills_demand.demand_count                       AS total_market_demand,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS entry_level_avg_salary,
    ROUND(average_salary.avg_salary, 0)              AS market_avg_salary,
    ROUND(AVG(job_postings_fact.salary_year_avg) 
        - average_salary.avg_salary, 0)              AS salary_gap,

    CASE
        WHEN COUNT(skills_job_dim.job_id) >= 200
            THEN 'Must-Learn'
        WHEN COUNT(skills_job_dim.job_id) >= 100 AND AVG(job_postings_fact.salary_year_avg) >= 80000
            THEN 'High Value'
        WHEN AVG(job_postings_fact.salary_year_avg) >= 90000
            THEN 'Advanced / Specialization'
        ELSE 'Nice to Have'
    END AS verdict

FROM job_postings_fact
    INNER JOIN skills_job_dim  ON job_postings_fact.job_id  = skills_job_dim.job_id
    INNER JOIN skills_dim      ON skills_job_dim.skill_id   = skills_dim.skill_id
    INNER JOIN skills_demand   ON skills_dim.skill_id       = skills_demand.skill_id
    INNER JOIN average_salary  ON skills_dim.skill_id       = average_salary.skill_id
WHERE
     (
        job_postings_fact.job_title_short = 'Data Analyst'
        OR job_postings_fact.job_title_short = 'Data Scientist'
        OR job_postings_fact.job_title_short = 'Data Engineer'
    )
    AND job_postings_fact.salary_year_avg IS NOT NULL
    AND (
        job_postings_fact.job_title ILIKE '%entry%'
        OR job_postings_fact.job_title ILIKE '%Intern%'
    )
GROUP BY
    skills_dim.skills,
    skills_demand.demand_count,
    average_salary.avg_salary
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    entry_level_demand DESC,
    entry_level_avg_salary DESC
LIMIT 25;


