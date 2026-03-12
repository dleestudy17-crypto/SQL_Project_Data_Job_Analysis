# Introduction
🎓 Built for college students breaking into data analytics! This project dives into the data analyst job market with one goal: helping students figure out where to focus their time and energy before they graduate. By analyzing real job postings, this project uncovers 💰 which data analyst roles pay the most, 🔥 which skills employers actually ask for at the senior level, and 📈 where high demand meets high salary so students can learn smarter, not harder.

🔍 SQL queries? Check them out here: [project_sql folder](/project_sql/)

# Background
As a college student studying Information Management and Technology, I wanted to go beyond generic career advice like "learn SQL and Python." This project analyzes real job postings to answer a more specific question: what do Data Analyst roles actually require, and what do they pay?

The dataset comes from Luke Barousse's SQL Course and contains job titles, salaries, locations, and required skills. Unlike most similar projects, I filtered specifically for high-paying Data Analyst roles with relevant technical skills— making this analysis directly relevant to college students preparing to enter the data analytics field.

### The questions I wanted to answer through my SQL queries were: 

1. top_paying_job_skills.sql → What are the top 100 highest-paying remote/on-site Data Analyst jobs in the United States, what skills do they require, and do they offer benefits or waive degree requirements?

2. top_demanded_skills.sql → Overall, which top 5 skills appear most frequently in Data Analyst postings in the United States?

3. different_level_job_skills.sql → What entry-level, associate, and junior Data Analyst job titles exist in the U.S. market, what do they pay, and what skills does each require?

4. optimal_skills.sql → What are the most optimal skills to learn — balancing high demand AND high salary — ranked by a student-friendly verdict label?

# Tools I Used
For my deep dive into the data analyst job market, I harnessed the power of several key tools:

- **SQL:** The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **PostgreSQL:** The chosen database management system, ideal for handling the job posting data.
- **Visual Studio Code:** My go-to for database management and executing SQL queries.
- **Git & GitHub:** Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking.

# The Analysis
Each query targets a specific question college students face when entering the data analytics job market. Here's how I approached each one:

## 1. Top Paying Data Analyst Jobs with Required Skills
This analysis explores the **highest-paying Data Analyst roles in the United States**, the **most in-demand skills required to land them**, **work location**, **degree requirements**, **health insurance** using job posting data from **2023–2025**.

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

## 📊 Top 20 Highest-Paid Data Analyst Roles out of 100 roles

![Top Paying Roles](assets/Top_20_roles_data_analysts.png)

*Bar chart showing the top 20 highest-paid Data Analyst roles by average annual salary.*

---

### 🛠️ Most Common Skills in Top 100 Paying Roles

> Across the highest-paying positions, **SQL and Python dominate by a wide margin**. They appear together in the majority of high-paying job postings.

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

## 📊 Most In-Demand Skills in Top 100 Paying Jobs

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

> Overall, the data suggests that **higher compensation is strongly correlated with in-person roles at major technology and finance companies.**

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

> These roles show that **demonstrated skills and experience can sometimes outweigh formal degree requirements**.

### 💰 Salary Distribution of Top Jobs
The highest-paying Data Analyst roles reach **$569,500 per year** (Akraya Inc).

* The **top 10 jobs** all exceed **$350,000**
* Even **rank 20** remains above **$275,000**

This suggests that **senior and director-level analytics roles can compete with software engineering salaries**, particularly in tech and finance.


## 🎯 Key Takeaways for Students

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



## 2. In-Demand Skills for Data Analysts

This analysis identifies **the most frequently requested skills in Data Analyst job postings in United States**, helping highlight the technologies candidates should prioritize when preparing for analytics roles.

The query aggregates skill demand across thousands of job listings and compares each skill’s demand relative to **SQL**, which serves as the industry baseline.

```sql
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
```

## 📈 Top 5 Most Requested Skills

Rank | Skill   | Mentioned In Job Postings | % of SQL Demand |
-----| ------- | ------------ | --------------- |
1    | SQL     | 77,619       | 100% (baseline) |
2    | Excel   | 61,794       | 80%             |
3    | Python  | 45,017       | 58%             |
4    | Tableau | 42,978       | 55%             |
5    | Power BI| 30,514       | 39%             |

*Table showing the demand for the top 5 skills in Data Analyst job postings.*

> **SQL is the most in-demand skill** appearing in 77K+ postings — nearly 3x more than Power BI.

> **Excel is far from dead** — at 80% of SQL's demand, it remains a core skill in most analyst roles.

> **Python and Tableau are nearly tied**, suggesting visualization skills are just as valued as programming.

> **Tableau dominates over Power BI** — learn Tableau first and add Power BI as a secondary skill.

## 🎯 Key Takeaway

### 1️⃣ SQL Is Non-Negotiable

**SQL appears in nearly 78,000 job postings**, making it the most in-demand skill by a large margin.

For aspiring analysts, **SQL is the single most essential technical skill** and forms the foundation for querying, transforming, and analyzing data.

### 2️⃣ Excel Remains Extremely Relevant

Despite being considered an “older” tool, **Excel appears in about 80% as many postings as SQL.**

This highlights that **spreadsheet-based analysis remains a critical part of many business workflows**, especially in finance, operations, and reporting.

### 3️⃣ Python vs Tableau Is Surprisingly Close

**Python appears in 45K job postings**, while **Tableau appears in ~43K postings**.

The small difference suggests that **data visualization skills are nearly as valuable as programming skills** in many analytics roles.

Companies often expect analysts not only to analyze data but also communicate insights visually.

### 4️⃣ Power BI Shows a Noticeable Drop

**Power BI appears in ~30K postings**, significantly lower than Tableau.

This suggests that **Tableau currently maintains a stronger position as the dominant visualization tool** in many analytics job postings.

---

## 3. Entry-Level, Associate & Junior Data Analyst Jobs — Salary & Skills

To help students understand **what to expect when entering the data analytics field**, this query identifies real U.S. job postings with entry-level, associate, or junior titles, showing what each role pays and what skills employers actually require.

```sql
SELECT
    job_postings_fact.job_title                             AS job_title,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0)        AS avg_salary,
    ROUND(MIN(job_postings_fact.salary_year_avg), 0)        AS min_salary,
    ROUND(MAX(job_postings_fact.salary_year_avg), 0)        AS max_salary,
    STRING_AGG(DISTINCT skills_dim.skills, ' | '
        ORDER BY skills_dim.skills)                         AS required_skills,
    COUNT(DISTINCT job_postings_fact.job_id)                AS job_demand
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
```

## 📊 Average Salary & Range by Job Titles (U.S. 2023-2025)

![Salary Range](assets/Data_Analyst_Salary_Range.png)

*Bar chart showing average salary and range by job title (U.S., 2023–2025)*

> Junior Data Analyst roles average **$100K+**, significantly higher than Entry-Level roles at **$53K–$68K** — a gap of up to $50K based on title alone. Notably, Junior Data Analyst has the widest salary range ($35K–$147K), meaning experience and company size heavily influence compensation. Students should target **Junior titles when possible** and avoid confusing "Data Entry Analyst" ($52K, clerical) with a true data analytics role.

## 📈 Required Skills by Job Title

| Job Title | Required Skills |
|-----------|----------------|
| Junior Data Analyst | `c++` `databricks` `docker` `excel` `flow` `github` `java` `javascript` `jenkins` `kubernetes` `oracle` `python` `sas` `spring` `tableau` `tensorflow` |
| Junior Data Scientist/Data Analyst | `c++` `docker` `java` `javascript` `jenkins` `python` `sas` `spring` `tableau` |
| junior data scientist/Data Analyst | `c++` `docker` `excel` `github` `java` `javascript` `jenkins` `kubernetes` `python` `pytorch` `sas` `spring` `tableau` `tensorflow` |
| Junior Data Analyst/Engineer/Scientist | `c++` `databricks` `docker` `excel` `java` `javascript` `jenkins` `python` `sas` `spring` `tableau` `tensorflow` |
| Entry Level DA w/ PowerBI | `c++` `databricks` `docker` `github` `java` `javascript` `jenkins` `python` `sas` `spring` `tableau` `tensorflow` |
| Technical Analyst - Entry Level | `c` `looker` `microstrategy` `power bi` `python` `sql` `tableau` |
| Entry/Junior Level Data Analyst/Scientist | `c++` `databricks` `docker` `github` `java` `javascript` `jenkins` `kubernetes` `oracle` `python` `spring` `tableau` `tensorflow` |
| Associate Data Analyst | `alteryx` `azure` `bash` `c#` `docker` `excel` `go` `hadoop` `java` `linux` `looker` `mysql` `oracle` `power bi` `python` `r` `sap` `sas` `sql` `sql server` `tableau` `word` |
| Entry Level Data Analyst | `aws` `azure` `databricks` `docker` `excel` `hadoop` `java` `javascript` `kubernetes` `looker` `mysql` `numpy` `oracle` `pandas` `power bi` `python` `r` `sas` `snowflake` `spark` `sql` `tableau` `tensorflow` `vba` |
| Junior Data Analyst | `airflow` `alteryx` `aws` `azure` `bigquery` `databricks` `docker` `excel` `github` `go` `hadoop` `java` `javascript` `jenkins` `jira` `kubernetes` `looker` `matlab` `mongodb` `mysql` `nosql` `oracle` `pandas` `power bi` `python` `pytorch` `r` `react` `sas` `scala` `scikit-learn` `sharepoint` `snowflake` `spark` `sql` `sql server` `tableau` `tensorflow` `terraform` `vba` `word` |
| Entry-Level Data Analyst | `excel` `power bi` `python` `sheets` `sql` `tableau` |
| Data Entry Analyst | `excel` `powerpoint` `word` |

*Skills aggregated across all postings for each title · Sorted by average salary descending*

> **Python and Tableau appear across nearly every role**, making them the two most universal skills regardless of title. Junior roles demand a significantly broader and more technical stack, with tools like `docker`, `kubernetes`, `tensorflow`, and `c++` appearing repeatedly, suggesting that **higher pay comes with higher technical expectations**. 

> In contrast, the most accessible titles like "Entry-Level Data Analyst" require only the core six: `sql` `excel` `python` `tableau` `power bi` `sheets`. Notably, "Data Entry Analyst" requires only `excel` `powerpoint` `word`, confirming it is a clerical role with no overlap with data analytics. For students, the clear starting stack is **SQL, Python, Excel, and Tableau**, then layer in cloud tools and engineering skills to move toward higher-paying Junior titles.

## 🎯 Key Takeaway

### 1️⃣ "Junior" Titles Pay Significantly More Than "Entry-Level"

Junior Data Analyst roles average $100K+, while Entry-Level roles average $53K–$68K.

The title alone can represent a $30K–$40K salary difference — worth targeting when job searching.

### 2️⃣ More Skills = Higher Pay

Top-paying junior roles consistently require a broader technical stack — Python, SQL, and Tableau plus tools like Docker, Kubernetes, and TensorFlow.

Building beyond the basics directly translates to higher compensation.

### 3️⃣ "Data Entry Analyst" Is Not a Data Analytics Role

At ~$52K with only Excel, PowerPoint, and Word required, this is a clerical position.

Students should be careful not to apply to these when targeting analytics roles.

### 4️⃣ "Entry Level Data Analyst" Has the Most Openings

With 66–140 postings, this is the most accessible title for new graduates. It offers the highest volume of opportunities to land your first analytics job.

### 5️⃣ The Salary Floor Is Lower Than Most Expect

Some entry-level roles start as low as $35,000–$42,500. Always check the min/max range — not just the average — when evaluating offers.