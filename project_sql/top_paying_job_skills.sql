/*
===============================================================
  File    : top_paying_jobs.sql
  Author  : Donghwan (Dylan) Lee
  Project : Data Job Market Analysis for College Students
===============================================================

  Question:
    What are the highest-paying Data Analyst jobs and
    what skills do they require?

  Approach:
    - Identifies the top 100 highest-paying Data Analyst roles
      with known salaries.

    - Uses DISTINCT ON to remove duplicate job postings when
      companies post the same role multiple times.

    - Aggregates required skills using STRING_AGG so that
      each job appears as a single row instead of repeating
      the job for every skill listed.

    - Includes student-relevant context such as:
        • Remote vs On-site work
        • Degree requirement
        • Health insurance availability
        • Skill categories

    - CASE statements convert raw TRUE/FALSE database values
      into readable labels.

    - INNER JOIN ensures that only jobs with documented
      skill requirements are included in the final results.

  Why this matters:
    Salary alone does not tell the full story.

    A $200K job requiring a rare degree and niche skills may
    be far less attainable for a student than a $130K role
    requiring common tools like SQL and Tableau.

    This query highlights both:
      • the highest-paying opportunities
      • the practical skills students need to reach them

===============================================================
*/

-- Identifies the top 100 highest-paying Data Analyst roles (Remote or On-site) in United States
-- including degree requirements, health insurance availability, and the skills required for each role
WITH top_paying_jobs AS (
    SELECT DISTINCT ON (company_dim.name, job_postings_fact.job_title)
        job_postings_fact.job_id,
        job_postings_fact.job_title,
        job_postings_fact.job_schedule_type,

        -- identify work location
        CASE
            WHEN job_postings_fact.job_work_from_home = TRUE THEN 'Remote'
            ELSE 'On-Site'
        END AS work_location_type,

        -- identify degree requirement
        CASE
            WHEN job_postings_fact.job_no_degree_mention = TRUE THEN 'No Degree Required'
            ELSE 'Degree Required'
        END AS degree_requirement,

        -- identify health insurance
        CASE
            WHEN job_postings_fact.job_health_insurance = TRUE THEN 'Yes'
            ELSE 'No'
        END AS health_insurance,

        job_postings_fact.job_posted_date::DATE AS date_posted,
        job_postings_fact.salary_year_avg,
        company_dim.name AS company_name

    FROM
        job_postings_fact
        LEFT JOIN company_dim
            ON job_postings_fact.company_id = company_dim.company_id

    WHERE
        job_postings_fact.job_title_short = 'Data Analyst'
        AND job_postings_fact.salary_year_avg IS NOT NULL
        AND job_postings_fact.job_country = 'United States'

    -- determines which duplicate to keep (most recent posting)
    ORDER BY
        company_dim.name,
        job_postings_fact.job_title,
        job_postings_fact.job_posted_date DESC
)

-- Joins skill data and consolidates multiple skills into one row per job
SELECT
    top_paying_jobs.job_id,
    top_paying_jobs.company_name,
    top_paying_jobs.job_title,
    top_paying_jobs.job_schedule_type,
    top_paying_jobs.work_location_type,
    top_paying_jobs.degree_requirement,
    top_paying_jobs.health_insurance,
    top_paying_jobs.date_posted,
    top_paying_jobs.salary_year_avg,

    -- combine skills
    STRING_AGG(DISTINCT skills_dim.skills, ', ' ORDER BY skills_dim.skills) AS skills,

    -- combine skill categories
    STRING_AGG(DISTINCT skills_dim.type, ', ') AS skill_categories

FROM
    top_paying_jobs

    -- keep INNER JOIN because jobs without skills are not useful
    INNER JOIN skills_job_dim
        ON top_paying_jobs.job_id = skills_job_dim.job_id

    INNER JOIN skills_dim
        ON skills_job_dim.skill_id = skills_dim.skill_id

GROUP BY
    top_paying_jobs.job_id,
    top_paying_jobs.company_name,
    top_paying_jobs.job_title,
    top_paying_jobs.job_schedule_type,
    top_paying_jobs.work_location_type,
    top_paying_jobs.degree_requirement,
    top_paying_jobs.health_insurance,
    top_paying_jobs.date_posted,
    top_paying_jobs.salary_year_avg

-- now rank jobs by salary
ORDER BY
    top_paying_jobs.salary_year_avg DESC

LIMIT 100;


