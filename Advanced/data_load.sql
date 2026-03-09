\copy company_dim 
FROM 'C:\Users\dhl77\OneDrive\바탕 화면\SQL_Project_Data_Job_Analysis\csv_files\company_dim.csvC:\Users\dhl77\OneDrive\바탕 화면\SQL_Project_Data_Job_Analysis\csv_files\company_dim.csvFORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim 
    FROM 'C:\Users\dhl77\OneDrive\바탕 화면\SQL_Project_Data_Job_Analysis\csv_files\skills_dim.csv' 
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact 
    FROM 'C:\Users\dhl77\OneDrive\바탕 화면\SQL_Project_Data_Job_Analysis\csv_files\job_postings_fact.csv' 
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim 
    FROM '/C:\Users\dhl77\OneDrive\바탕 화면\SQL_Project_Data_Job_Analysis\csv_files\skills_job_dim.csv' 
    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');