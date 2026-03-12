# Introduction
🎓 Built for college students breaking into data analytics! This project dives into the data analyst job market with one goal: helping students figure out where to focus their time and energy before they graduate. By analyzing real job postings, this project uncovers 💰 which data analyst roles pay the most, 🔥 which skills employers actually ask for at the senior level, and 📈 where high demand meets high salary so students can learn smarter, not harder.

🔍 SQL queries? Check them out here: [project_sql folder](/project_sql/)

# Background
As a college student studying Information Management and Technology, I wanted to go beyond generic career advice like "learn SQL and Python." This project analyzes real job postings to answer a more specific question: what do Data Analyst roles actually require, and what do they pay?

The dataset comes from Luke Barousse's SQL Course and contains job titles, salaries, locations, and required skills. Unlike most similar projects, I filtered specifically for high-paying Data Analyst roles with relevant technical skills— making this analysis directly relevant to college students preparing to enter the data analytics field.

### The questions I wanted to answer through my SQL queries were: 

1. top_paying_jobs.sql → What are the top 100 highest-paying remote/on-site Data Analyst jobs in the United States, what skills do they require, and do they offer benefits or waive degree requirements?

2. top_demanded_skills.sql → Which skills appear most frequently in entry-level, associate, and junior Data Analyst postings — and how do they split between remote and on-site roles?

3. top_paying_skills.sql → Among entry-level and associate Data Analyst roles, which skills are associated with the highest average salaries?

4. optimal_skills.sql → What are the most optimal skills to learn — balancing high demand AND high salary — ranked by a student-friendly verdict label?

# Tools I Used
For my deep dive into the data analyst job market, I harnessed the power of several key tools:

- **SQL:** The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **PostgreSQL:** The chosen database management system, ideal for handling the job posting data.
- **Visual Studio Code:** My go-to for database management and executing SQL queries.
- **Git & GitHub:** Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking.

# The Analysis
Each query targets a specific question college students face when entering the data analytics job market. Here's how I approached each one:

### 1. Top Paying Data Analyst Jobs with Required Skills
To identify the **highest-paying Data Analyst roles**, I created a query that selects the **top 100 jobs by average yearly salary** from the lowest to the hightest and connects them to the skills required for each position.

The query first uses a **CTE (`top_paying_jobs`)** to filter roles with salary data and rank them from highest to lowest pay. It also adds useful context such as **work location (Remote vs On-Site), degree requirements, and health insurance availability**.

Finally, the query joins the skills tables and uses **`STRING_AGG`** to combine multiple skills into a single row per job, creating a cleaner dataset that is easier to analyze.


```sql
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
```
## 📊 Key Insights from the Top-Paying Data Analyst Jobs (2023–2025)

This analysis explores the **highest-paying Data Analyst roles** and the **skills required to land them** using job posting data from **2023–2025**.

### 💰 Salary Distribution of Top Jobs
The highest-paying Data Analyst roles reach **$569,500 per year** (Akraya Inc).

* The **top 10 jobs** all exceed **$350,000**
* Even **rank 20** remains above **$275,000**

This suggests that **senior and director-level analytics roles can compete with software engineering salaries**, particularly in tech and finance.

### 📊 Top 20 Highest-Paid Data Analyst Roles out of 100 roles

![Top Paying Roles](assets/Top_20_roles_data_analysts.png)

*Bar chart showing the top 20 highest-paid Data Analyst roles by average annual salary.*

---

### 🛠️ Most Common Skills in Top 100 Paying Roles

Across the highest-paying positions, **SQL and Python dominate by a wide margin**. They appear together in the majority of high-paying job postings.

The typical high-value analytics stack includes:

**Core Data Skills**

* SQL
* Python

**Visualization**

* Tableau
* Power BI

**Cloud & Big Data**

* AWS
* Azure
* Google Cloud

**Advanced Analytics Tools**

* R
* Spark
* Snowflake

### 📊 Most In-Demand Skills in Top 100 Paying Jobs

![Most Common Skills](assets/Most_common_skills_in_Top_Paying_roles.png)

*Bar chart showing the 15 most frequently required skills across the top-paying Data Analyst roles.*

---

### 🏢 Work Location Distribution (Top 100 Jobs)

| Work Location | Percentage |
| ------------- | ---------- |
| On-Site       | ~94%       |
| Remote        | ~6%        |

> Contrary to popular perception, the **highest-paying Data Analyst roles are overwhelmingly on-site**.

Remote roles do exist but are rare in this salary tier. Companies offering remote positions among the top-paying jobs include:

* Netflix
* Pinterest
* Atlassian
* Nurp

Overall, the data suggests that **higher compensation is strongly correlated with in-person roles at major technology and finance companies.**

---

### 🎓 Degree Requirement (Top 100 Jobs)

| Degree Requirement | Percentage |
| ------------------ | ---------- |
| Degree Required    | ~70%       |
| No Degree Required | ~30%       |

> Notable companies offering high-paying roles without a degree requirement include:
> - Netflix ($445K)  
> - Edge & Node ($264K)  
> - SimplePractice ($172.5K)  
> - Zscaler ($152.6K)  
> - Rocket Money ($152.5K)  
> - ServiceNow ($164K)  

---

While most high-paying roles still expect a degree, **nearly one-third do not explicitly require one**.

### Examples of High-Paying Roles Without Degree Requirements

| Company      | Salary   | Role                                   |
| ------------ | -------- | -------------------------------------- |
| Akraya Inc   | $569,500 | Digital Advertising Analytics          |
| Yoh          | $510,000 | Power BI Data Analyst                  |
| MassGenics   | $450,000 | Database/Data Analyst                  |
| Netflix      | $445,000 | Analytics Engineer                     |
| Anthropic    | $350,000 | Data Analyst                           |
| OpenAI       | $270,000 | Data Visualization Analyst             |
| Google       | $254,000 | Partner Technology Manager (Data & AI) |
| Augment Code | $262,500 | Fraud Data Analyst                     |

These roles show that **demonstrated skills and experience can sometimes outweigh formal degree requirements**.

---

# 🎯 Key Takeaways for Students

Several clear patterns emerge from the data:

### 1️⃣ SQL and Python Are Non-Negotiable

These two skills appear in **over 70% of top-paying roles**.

### 2️⃣ Visualization Skills Are Essential

Tools such as **Tableau and Power BI** consistently appear as supporting requirements.

### 3️⃣ Cloud & Data Platforms Add Competitive Advantage

Experience with **AWS, Azure, Snowflake, and Spark** is common in higher-paying positions.

### 4️⃣ Degrees Still Matter — But They Are Not Everything

While **70% of roles require a degree**, roughly **1 in 3 top-paying jobs do not**.

A strong portfolio, certifications, and project experience can significantly offset the lack of a formal degree.

### 5️⃣ Highest Salaries Are Mostly On-Site

Despite the growth of remote work, **the highest-paying analytics roles remain largely on-site**, particularly in tech and financial institutions.

---

# 🚀 Final Insight

For aspiring data analysts, the path to high-paying roles is clear:

**Master SQL → Learn Python → Build visualization skills → Gain experience with cloud tools → Build a strong portfolio.**

Those who combine these skills with real-world projects and business context position themselves strongly for the highest-paying opportunities in the data analytics field.

---