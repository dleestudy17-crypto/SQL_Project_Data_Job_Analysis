/*
**Question: What are the most in-demand skills for data analysts?**

- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings to see how many times a certain skill name was mentioned.
- Why? Retrieves the top 5 skills with the highest demand in the job market, providing 
insights into the most valuable skills for job seekers.
*/
-- Identifies the top 5 most demanded skills for Data Analyst job postings
SELECT
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
    AND job_postings_fact.job_country = 'United States'
GROUP BY
  skills_dim.skills
ORDER BY
  demand_count DESC
LIMIT 5;

-- Fixed Code For All Countries
SELECT
  skills_dim.skills,
  COUNT(skills_job_dim.job_id) AS demand_count
FROM
  job_postings_fact
  INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_postings_fact.job_title_short ILIKE 'Data Analyst'
GROUP BY
  skills_dim.skills
ORDER BY
  demand_count DESC
LIMIT 5;

SELECT
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    CONCAT(
        ROUND(
            COUNT(skills_job_dim.job_id) * 100.0 /
            (
                SELECT COUNT(skills_job_dim2.job_id)
                FROM job_postings_fact f2
                INNER JOIN skills_job_dim skills_job_dim2 ON f2.job_id = skills_job_dim2.job_id
                INNER JOIN skills_dim skills_dim2 ON skills_job_dim2.skill_id = skills_dim2.skill_id
                WHERE f2.job_title_short ILIKE 'Data Analyst'
                AND skills_dim2.skills = 'sql'
            ),
        0), '%'
    ) AS percentage_of_sql_demand
FROM
    job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_postings_fact.job_title_short ILIKE 'Data Analyst'
GROUP BY
    skills_dim.skills
ORDER BY
    demand_count DESC
LIMIT 5;

--Updated Code
-- Retrieves the top 5 most in-demand skills for Data Analyst roles globally
-- and calculates each skill's demand relative to SQL as a baseline
SELECT
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,

    -- If the skill is SQL, hardcode '100% (baseline)'
    -- Otherwise calculate the percentage dynamically
    CASE
        WHEN skills_dim.skills = 'sql'
            THEN '100% (baseline)'
        ELSE
            -- Combine the rounded percentage with a % sign into one text value
            CONCAT(
                -- Round to 0 decimal places
                ROUND(
                    -- Divide current skill's demand by SQL's demand
                    -- Multiply by 100.0 to force decimal division
                    COUNT(skills_job_dim.job_id) * 100.0 /

                        -- Subquery to get SQL's total demand count
                        -- This runs once and returns a single number
                        (
                            SELECT COUNT(sql_skills_job.job_id)
                            FROM job_postings_fact AS sql_postings
                            INNER JOIN skills_job_dim AS sql_skills_job
                                ON sql_postings.job_id = sql_skills_job.job_id
                            INNER JOIN skills_dim AS sql_skills
                                ON sql_skills_job.skill_id = sql_skills.skill_id
                            -- Filter to Data Analyst roles and SQL only
                            WHERE sql_postings.job_title_short ILIKE 'Data Analyst'
                            AND sql_skills.skills = 'sql'
                        ),
                0), '%'  -- Append % sign after the rounded number
            )
    END AS pct_of_sql_demand

FROM
    job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id

WHERE
    -- Filter to Data Analyst roles only
    job_postings_fact.job_title_short ILIKE 'Data Analyst'

GROUP BY
    skills_dim.skills

-- Sort by highest demand first
ORDER BY
    demand_count DESC

LIMIT 5;