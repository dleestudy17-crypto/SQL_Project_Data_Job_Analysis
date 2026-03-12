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

## 1. Top Paying Data Analyst Jobs with Required Skills in the United States (2023-2025)
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

## 📊 Results

| # | Company | Job Title | Salary | Skills | Location | Degree | Health Insurance |
|:-:|---------|-----------|:------:|--------|:--------:|:------:|:---------------:|
| 1 | Akraya Inc | Data Analyst w/ Digital Advertising | $569,500 | `looker` `power bi` `python` `sql` `tableau` | On-Site | Not Required | No |
| 2 | Yoh | Power BI Data Analyst | $510,000 | `mysql` `power bi` `snowflake` | On-Site | Not Required | Yes |
| 3 | MassGenics | VMO Data Consultant V | $450,000 | `excel` `sql` | On-Site | Not Required | Yes |
| 4 | Netflix | Analytics Engineer – Playback Data (L5) | $445,000 | `go` `python` `scala` `sql` `typescript` | Remote | Required | Yes |
| 5 | Netflix | Analytics Engineer – Live QoE (L5) | $445,000 | `python` `sql` | Remote | Not Required | Yes |
| 6 | Torc Robotics | Director of Safety Data Analysis | $375,000 | `airflow` `excel` `matlab` `power bi` `python` `r` `sas` `spark` `sql` `tableau` | On-Site | Required | Yes |
| 7 | Illuminate Mission Solutions | HC Data Analyst, Senior | $375,000 | `excel` `python` `r` `tableau` `vba` | On-Site | Required | No |
| 8 | Citigroup | Head of Infra Mgmt & Data Analytics | $375,000 | `excel` `word` | On-Site | Required | No |
| 9 | Care.com | Head of Data Analytics | $350,000 | `bigquery` `looker` `power bi` `python` `r` `snowflake` `sql` `tableau` | On-Site | Required | Yes |
| 10 | Anthropic | Data Analyst | $350,000 | `python` `sql` | On-Site | Not Required | Yes |
| 11 | Advocates Legal Recruiting | Associate – Data, Privacy & Cybersecurity | $325,000 | `gdpr` | On-Site | Not Required | Yes |
| 12 | beBeeDataScience | Analytics Expert | $315,000 | `python` `sql` | On-Site | Not Required | No |
| 13 | beBeeData | Platform Performance Data Analyst | $315,000 | `python` `sql` | On-Site | Required | No |
| 14 | Storm2 | Quantitative Engineer | $315,000 | `airflow` `aws` `docker` `mysql` `numpy` `pandas` `python` `scikit-learn` `terraform` | On-Site | Required | No |
| 15 | beBeeDataAnalyst | Unlock Business Potential as a Data Analyst | $310,000 | `python` `scala` `spark` `sql` | On-Site | Not Required | Yes |
| 16 | Capital One | Applied Researcher II | $305,000 | `aws` `pytorch` | On-Site | Required | Yes |
| 17 | beBeeDataScientist | Efficient Data Analyst – Advertising | $285,818 | `sql` | On-Site | Required | No |
| 18 | OpenAI | Research Scientist | $285,000 | `github` | On-Site | Required | Yes |
| 19 | PwC | Financial Services – Data & Tech Director | $282,500 | `aws` `azure` `flow` `python` `r` `sas` `snowflake` `sql` | On-Site | Required | Yes |
| 20 | Selby Jennings | Data Operations Analyst | $275,000 | `linux` `sql` `sql server` `windows` | On-Site | Required | No |
| 21 | Odaseva | Product Data Analyst | $275,000 | `excel` `looker` `sql` `tableau` | On-Site | Required | No |
| 22 | USAA | Exec Dir, Business and Data Analytics | $273,320 | `phoenix` | On-Site | Required | Yes |
| 23 | OpenAI | Data Visualization Analyst | $270,000 | `looker` `power bi` `python` `react` `sql` `tableau` | On-Site | Not Required | No |
| 24 | Northrop Grumman | Data Analyst 6 Jobs | $265,000 | `python` `sql` `tableau` | On-Site | Required | Yes |
| 25 | beBeeEmergingTech | Tax Data Analyst – Emerging Tech | $264,000 | `power bi` `sharepoint` `sql` `sql server` | On-Site | Required | Yes |

⋮

*Table showing the top 100 highest-paying U.S. Data Analyst roles sorted by average annual salary (2023–2025) · Showing 25 of 100 rows*


## 📊 Top 20 Highest-Paid Data Analyst Roles out of 100 Roles (Director & Senior Level)

![Top Paying Roles](assets/Top_20_roles_data_analysts.png)

*Bar chart showing the top 20 highest-paid Data Analyst roles by average annual salary.*

---

### 💰 Salary Distribution of Top Jobs
The highest-paying Data Analyst roles reach **$569,500 per year** (Akraya Inc).

* The **top 10 jobs** all exceed **$350,000**
* Even **rank 20** remains above **$275,000**

This suggests that **senior and director-level analytics roles can compete with software engineering salaries**, particularly in tech and finance.

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


## 2. In-Demand Skills for Data Analyst Roles Worldwide

This analysis identifies **the most frequently requested skills in Data Analyst job postings across all countries**, providing a global perspective on what employers consistently look for in data analyst candidates.

The query aggregates skill demand across hundreds of thousands of job listings worldwide and compares each skill's demand relative to **SQL**, which serves as the industry baseline.

```sql
SELECT
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    CASE
        WHEN skills_dim.skills = 'sql'
            THEN '100% (baseline)'
        ELSE
            CONCAT(
                ROUND(
                    COUNT(skills_job_dim.job_id) * 100.0 /
                        (
                            SELECT COUNT(sql_skills_job.job_id)
                            FROM job_postings_fact AS sql_postings
                            INNER JOIN skills_job_dim AS sql_skills_job
                                ON sql_postings.job_id = sql_skills_job.job_id
                            INNER JOIN skills_dim AS sql_skills
                                ON sql_skills_job.skill_id = sql_skills.skill_id
                            WHERE sql_postings.job_title_short ILIKE 'Data Analyst'
                            AND sql_skills.skills = 'sql'
                        ),
                0), '%' 
            )
    END AS pct_of_sql_demand

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
```

## 📈 Results: Top 5 Most Requested Skills (Global)

| Rank | Skill    | Job Postings | % of SQL Demand |
|:----:|----------|-------------:|:---------------:|
| 1    | SQL      | 198,761      | 100% (baseline) |
| 2    | Excel    | 144,995      | 73%             |
| 3    | Python   | 128,946      | 65%             |
| 4    | Tableau  | 99,062       | 50%             |
| 5    | Power BI | 94,631       | 48%             |

*Table showing the most common skills required in Data Analyst job postings globally.*

> **SQL dominates globally** appearing in nearly 200,000 postings, more than any other skill by a wide margin.

> **Excel remains essential worldwide** at 73% of SQL's demand, confirming it is a universal workplace tool across industries and countries.

> **Python and Tableau are both highly valued** at 65% and 50% of SQL's demand, suggesting programming and visualization skills are equally important globally.

> **Power BI and Tableau are nearly tied globally**, indicating stronger Power BI adoption in international markets compared to the U.S.

### 🎯 Key Takeaways

**SQL is non-negotiable** — appearing in nearly 200,000 postings globally, it is the single most in-demand skill and the foundation for any data analyst role regardless of industry or country.

**Excel remains a core workplace tool** — at 73% of SQL's demand, spreadsheet skills are still critical in finance, operations, and reporting workflows worldwide.

**Python and Tableau are both essential** — companies expect analysts to analyze data programmatically and communicate insights visually, making both skills equally important to develop.

**Power BI is more competitive globally than in the U.S.** — nearly matching Tableau at the global level, students targeting multinational companies should consider learning both visualization tools.


## 3. Entry-Level, Associate & Junior Data Analyst Jobs in the United States — Salary & Skills

To help students understand **what to expect when entering the data analytics field**, this query identifies real U.S. job postings with entry-level, associate, or junior titles, showing what each role pays and what skills employers actually require.

```sql
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
```
### 📊 Results

| Job Title | Avg Salary | Min Salary | Max Salary | Job Demand | Required Skills |
|-----------|:---------:|:---------:|:---------:|:---------:|----------------|
| Junior Data Analyst | $102,569 | $80,000 | $115,000 | 24 | `c++` `databricks` `docker` `excel` `flow` `github` `java` `javascript` `jenkins` `kubernetes` `oracle` `python` `sas` `spring` `tableau` `tensorflow` |
| Junior Data Scientist/Data Analyst | $100,565 | $100,000 | $105,000 | 29 | `c++` `docker` `java` `javascript` `jenkins` `python` `sas` `spring` `tableau` |
| junior data scientist/Data Analyst | $99,649 | $72,000 | $120,000 | 49 | `c++` `docker` `excel` `github` `java` `javascript` `jenkins` `kubernetes` `python` `pytorch` `sas` `spring` `tableau` `tensorflow` |
| Junior Data Analyst/Engineer/Scientist | $96,466 | $70,000 | $110,000 | 11 | `c++` `databricks` `docker` `excel` `java` `javascript` `jenkins` `python` `sas` `spring` `tableau` `tensorflow` |
| Entry Level DA w/ PowerBI | $95,345 | $95,000 | $100,000 | 13 | `c++` `databricks` `docker` `github` `java` `javascript` `jenkins` `python` `sas` `spring` `tableau` `tensorflow` |
| Technical Analyst - Entry Level | $80,550 | $80,550 | $80,550 | 31 | `c` `looker` `microstrategy` `power bi` `python` `sql` `tableau` |
| Entry/Junior Level DA/Scientist | $79,680 | $75,000 | $97,500 | 22 | `c++` `databricks` `docker` `github` `java` `javascript` `jenkins` `kubernetes` `oracle` `python` `spring` `tableau` `tensorflow` |
| Associate Data Analyst | $71,787 | $37,400 | $90,500 | 40 | `alteryx` `azure` `bash` `c#` `docker` `excel` `go` `hadoop` `java` `linux` `looker` `mysql` `oracle` `power bi` `python` `r` `sap` `sas` `sql` `sql server` `tableau` `word` |
| Entry Level Data Analyst | $67,819 | $42,500 | $97,500 | 66 | `aws` `azure` `databricks` `docker` `excel` `hadoop` `java` `javascript` `kubernetes` `looker` `mysql` `numpy` `oracle` `pandas` `power bi` `python` `r` `sas` `snowflake` `spark` `sql` `tableau` `tensorflow` `vba` |
| Junior Data Analyst | $63,371 | $35,000 | $147,000 | 140 | `airflow` `alteryx` `aws` `azure` `bigquery` `databricks` `docker` `excel` `github` `go` `hadoop` `java` `javascript` `jenkins` `jira` `kubernetes` `looker` `matlab` `mongodb` `mysql` `nosql` `oracle` `pandas` `power bi` `python` `pytorch` `r` `react` `sas` `scala` `scikit-learn` `sharepoint` `snowflake` `spark` `sql` `sql server` `tableau` `tensorflow` `terraform` `vba` `word` |
| Entry-Level Data Analyst | $53,245 | $45,000 | $90,000 | 18 | `excel` `power bi` `python` `sheets` `sql` `tableau` |
| Data Entry Analyst | $51,903 | $43,000 | $52,500 | 13 | `excel` `powerpoint` `word` |

*Table showing entry-level, associate, and junior Data Analyst roles with salary ranges, job demand, and required skills (U.S., 2023–2025) · Sorted by average salary descending*

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

## 4. Optimal Skills for Entry-Level & Intern Data Roles (U.S., 2023–2025)

Now that we have a comprehensive understanding of salary ranges across 
different role levels and required skills both globally and domestically, 
this query answers one final question for students: **which skills should 
I learn first to maximize my chances of getting hired and getting paid well 
in entry-level and intern data roles?**

To answer this, the query combines four key metrics per skill:

- Entry-level demand
- Total market demand
- Entry-level average salary
- Market-wide average salary
- Salary gap

Each skill is then assigned a verdict label so students know exactly 
where to focus their learning effort.

```sql
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
```
### 📊 Results

| Skill | Entry-Level Demand | Total Market Demand | Entry-Level Avg Salary | Market Avg Salary | Salary Gap | Verdict |
|-------|:-----------------:|:-------------------:|:----------------------:|:-----------------:|:----------:|---------|
| python | 592 | 24,363 | $83,965 | $134,250 | -$50,285 | Must-Learn |
| sql | 434 | 24,595 | $75,873 | $126,048 | -$50,175 | Must-Learn |
| tableau | 341 | 9,529 | $80,510 | $114,775 | -$34,265 | Must-Learn |
| excel | 259 | 10,073 | $67,575 | $94,973 | -$27,398 | Must-Learn |
| sas | 236 | 3,144 | $87,545 | $112,904 | -$25,358 | Must-Learn |
| java | 231 | 4,581 | $90,245 | $136,564 | -$46,319 | Must-Learn |
| power bi | 224 | 6,697 | $72,594 | $108,162 | -$35,569 | Must-Learn |
| r | 217 | 10,078 | $85,323 | $128,394 | -$43,071 | Must-Learn |
| tensorflow | 158 | 2,518 | $86,685 | $144,032 | -$57,347 | High Value |
| javascript | 155 | 1,716 | $88,698 | $114,393 | -$25,695 | High Value |
| c++ | 150 | 1,635 | $93,110 | $125,969 | -$32,859 | High Value |
| spring | 129 | 788 | $91,150 | $111,430 | -$20,280 | High Value |
| docker | 113 | 1,989 | $91,838 | $133,952 | -$42,113 | High Value |
| jenkins | 110 | 1,138 | $92,205 | $123,531 | -$31,326 | High Value |
| oracle | 107 | 2,645 | $88,239 | $121,177 | -$32,938 | High Value |
| databricks | 89 | 3,508 | $87,532 | $135,404 | -$47,872 | Nice to Have |
| azure | 86 | 6,657 | $83,863 | $134,351 | -$50,488 | Nice to Have |
| powerpoint | 74 | 1,991 | $60,011 | $96,462 | -$36,451 | Nice to Have |
| github | 69 | 1,470 | $90,209 | $125,468 | -$35,259 | Advanced / Specialization |
| spark | 69 | 5,976 | $86,942 | $148,309 | -$61,367 | Nice to Have |
| aws | 62 | 8,059 | $91,276 | $141,615 | -$50,339 | Advanced / Specialization |
| word | 60 | 2,341 | $59,043 | $93,339 | -$34,295 | Nice to Have |
| sql server | 53 | 2,290 | $79,233 | $111,993 | -$32,761 | Nice to Have |
| hadoop | 45 | 3,318 | $81,556 | $144,379 | -$62,824 | Nice to Have |
| looker | 45 | 1,401 | $78,313 | $130,453 | -$52,140 | Nice to Have |

*Table showing the top 25 optimal skills for entry-level and intern data roles in the U.S. (2023–2025), sorted by entry-level demand.*

## 🎯 Demand vs. Average Salary — Entry-Level & Intern Roles (U.S.)

![Demand vs. Average Salary](assets/Demand_vs_Average_Salary.png)

*The scatter plot showing the relationship between entry-level demand and average salary per skill, where dot size represents total market demand and color indicates the verdict label (Must-Learn, High Value, Advanced/Specialization, Nice to Have).*

> **Python, SQL, and Tableau dominate entry-level demand** with 592, 434, and 341 postings respectively, making them the three highest priority skills for students to learn first.

> **A broader foundational stack is expected from day one** with 8 Must-Learn skills all appearing in 200 or more entry-level postings including Excel, SAS, Java, Power BI, and R.

> **Every entry-level salary sits below market rate** with gaps ranging from $20K to $62K, confirming that the first role is a stepping stone rather than a salary ceiling.

## 🎯 Key Takeaways

### 1️⃣ Start With Python and SQL

Python and SQL appear in 592 and 434 entry-level postings respectively, making them the two highest priority skills for any student entering a data role.

Mastering these two alone covers the majority of entry-level job requirements.

### 2️⃣ A Broad Foundational Stack Is Expected From Day One

Eight skills including Tableau, Excel, SAS, Java, Power BI, and R all appear in 200 or more entry-level postings.

Students should not stop at Python and SQL — employers expect a well-rounded skill set even at the entry level.

### 3️⃣ Higher Pay Comes With a More Technical Stack

Tools like Docker, Jenkins, C++, and Spring average $91K to $93K at entry level but appear in only 110 to 150 postings.

These are strong second-stage learning goals once the foundational stack is solid.

### 4️⃣ Every Entry-Level Salary Sits Below Market Rate

Salary gaps range from $20K to $62K compared to the broader market, meaning entry-level pay is significantly lower than what experienced professionals earn for the same skills.

Students should treat the first role as a launching pad rather than a salary ceiling.

### 5️⃣ AWS and GitHub Are Worth Learning Later

Both pay above $90K at entry level but appear in fewer than 70 postings, categorizing them as Advanced skills.

Prioritize the core stack first and add cloud and version control skills once the fundamentals are covered.