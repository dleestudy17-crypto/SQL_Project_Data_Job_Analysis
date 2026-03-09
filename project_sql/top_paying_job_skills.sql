/*
===============================================================
  File    : top_paying_jobs.sql
  Author  : Donghwan (Dylan) Lee
  Project : Data Job Market Analysis for College Students
===============================================================

  Question: What are the top-paying remote Data Analyst jobs,
            and what skills do they require?

  Approach:
    - Pulls the top 100 highest-paying remote Data Analyst roles
    - Uses STRING_AGG to consolidate all required skills into
      one clean row per job instead of repeating the job
    - Adds student-friendly context: degree requirement,
      health insurance, work location type, and skill categories
    - CASE statements convert TRUE/FALSE values into readable labels

  Why?
    Salary alone does not tell the full story. A $200K job that
    requires a specific degree and rare skills is not as useful
    to a student as a $130K job with no degree requirement and
    common skills. This query surfaces both the opportunity
    and the realistic path to get there.

===============================================================
*/

-- Identifies the top 100 highest-paying remote Data Analyst roles
-- and the skills required to land them
WITH top_paying_jobs AS (
    SELECT
        job_postings_fact.job_id,
        job_postings_fact.job_title,
        job_postings_fact.job_location,
        job_postings_fact.job_schedule_type,
        CASE
            WHEN job_postings_fact.job_work_from_home = TRUE THEN 'Remote'
            ELSE 'On-Site'
        END AS work_location_type,
        CASE
            WHEN job_postings_fact.job_no_degree_mention = TRUE THEN 'No Degree Required'
            ELSE 'Degree Required'
        END AS degree_requirement,
        CASE
            WHEN job_postings_fact.job_health_insurance = TRUE THEN 'Yes'
            ELSE 'No'
        END AS health_insurance,
        job_postings_fact.job_posted_date::DATE AS date_posted,
        job_postings_fact.salary_year_avg,
        company_dim.name AS company_name
    FROM
        job_postings_fact
        LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_postings_fact.job_title_short = 'Data Analyst'
        AND job_postings_fact.salary_year_avg IS NOT NULL
        AND (
            job_postings_fact.job_work_from_home = TRUE
            OR job_postings_fact.job_location    = 'Anywhere'
        )
    ORDER BY
        job_postings_fact.salary_year_avg DESC
    LIMIT 100
)

-- Joins skill data and consolidates multiple skills into one row per job
SELECT
    top_paying_jobs.job_id,
    top_paying_jobs.company_name,
    top_paying_jobs.job_title,
    top_paying_jobs.job_location,
    top_paying_jobs.job_schedule_type,
    top_paying_jobs.work_location_type,
    top_paying_jobs.degree_requirement,
    top_paying_jobs.health_insurance,
    top_paying_jobs.date_posted,
    top_paying_jobs.salary_year_avg,
    STRING_AGG(skills_dim.skills, ', ' ORDER BY skills_dim.skills)  AS skills,
    STRING_AGG(DISTINCT skills_dim.type, ', ')                       AS skill_categories
FROM
    top_paying_jobs
    INNER JOIN skills_job_dim ON top_paying_jobs.job_id  = skills_job_dim.job_id
    INNER JOIN skills_dim     ON skills_job_dim.skill_id = skills_dim.skill_id
GROUP BY
    top_paying_jobs.job_id,
    top_paying_jobs.company_name,
    top_paying_jobs.job_title,
    top_paying_jobs.job_location,
    top_paying_jobs.job_schedule_type,
    top_paying_jobs.work_location_type,
    top_paying_jobs.degree_requirement,
    top_paying_jobs.health_insurance,
    top_paying_jobs.date_posted,
    top_paying_jobs.salary_year_avg
ORDER BY
    top_paying_jobs.salary_year_avg DESC;