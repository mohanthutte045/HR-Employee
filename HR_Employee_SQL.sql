create database hr;

use hr;

select * from hr_employee_clean;

alter table hr_employee_clean rename  to HR;

select * from HR;

alter table HR drop column MyUnknownColumn;


-- 1. Display the first 10 rows from the table. 
select * from HR limit  10;

-- 2. Find the total number of employees in the company. 
select count(employeeCount) from HR;

-- 3. List all unique departments. 
select distinct(Department) from HR;

-- 4. Show how many employees have left the company and how many are still working. 
select 
	case when Attrition = 'Yes' then 'Left' else 'Still Working' end as status,
    count(*) as employees from HR group by Attrition;
     

-- 5. Retrieve the list of employees who work overtime. 
select * from HR where Overtime = 'Yes';

-- 6. Find the average monthly income of all employees. 
select * from HR;
select   round(avg(MonthlyIncome),2) from HR;

-- 7. Identify employees whose number of companies worked is missing (NULL). 
select * from HR where NumCompaniesWorked = 'Null';

-- 8. Find the employee(s) with the maximum monthly income. 
select  * from HR where MonthlyIncome = (Select max(MonthlyIncome) from hr);

-- 9. Count the number of employees by gender. 
select gender,count(Gender) from HR group by Gender;

-- 10. List all employees who have just joined (YearsAtCompany = 0). 
select * from HR where YearsAtCompany = 0;

-- 11. Calculate the attrition rate (%) by department. 
select Department , count(*) as Total_employees ,
	sum(case when Attrition = 'Yes' then 1 else 0 end) as leavers,
    round(100.0 * sum(case when Attrition = 'Yes' then 1 else 0 end)/ count(*),2) as  attrition_rate
    from hr group by Department;

-- 12. List the top 10 employees with the highest total working years. 
select EmployeeNumber, JobRole,Department, TotalWorkingYears from hr order by TotalWorkingYears Desc limit 10;

-- 13. Group employees into tenure categories (<1yr, 1–3yr, 4–6yr, 7+yr) and count employees in 
-- each. 
select case when YearsAtCompany < 1 then '<1yr'
            when YearsAtCompany <= 3 then '1-3 yr'
            when YearsAtCompany <= 6 then '4-6 yr'
            else '7+ yr' end as tenure_categories,
count(*) as employees from hr 
group by 1 order by min(YearsAtCompany);

-- 14. Find the average monthly income by job level and attrition status. 
select JobLevel, Attrition , round(Avg(MonthlyIncome),2) as avg_monthly_income
from hr group by JobLevel, Attrition order by JobLevel , Attrition;

-- 15. Identify the top 5 job roles with the highest number of employees who left. 
select JobRole, count(*) as leavers from hr where Attrition = 'Yes' group by JobRole order by leavers desc limit 5;

-- 16. List employees who left the company within their first year. 
select * from hr where Attrition = 'Yes' and YearsAtCompany <=1;

-- 17. Calculate each employee’s approximate new monthly compensation after applying their 
-- salary hike percentage. 
select EmployeeNumber, MonthlyIncome, PercentSalaryHike,
    round(MonthlyIncome * (1 + PercentSalaryHike / 100), 2) as new_monthly_income 
    from hr;
select * from hr;

-- 18. Count employees grouped by overtime status and attrition. 
select OverTime,Attrition,count(*) from hr group by OverTime , Attrition order by OverTime , Attrition ;

-- 19. Display the top 10 employees who attended the most training sessions last year. 
select TrainingTimesLastYear , EmployeeNumber, JobRole from hr order by TrainingTimesLastYear desc limit 10;

-- 20. Rank employees by total working years (most experienced = rank 1). 
select EmployeeNumber , TotalWorkingYears, rank() over(order by TotalWorkingYears desc ) as ranks from hr;

-- 21. For each department, find employees whose monthly income is in the top 25% of that 
-- department. 
SELECT *
FROM (
    SELECT hr.*,
           percent_rank() OVER (PARTITION BY Department ORDER BY MonthlyIncome DESC) AS income_quartile
    FROM hr
) t
WHERE income_quartile <= 0.25;

select MonthlyIncome from hr;

-- 22. Divide employees into 10 income deciles and find attrition rate for each decile. 
SELECT income_decile,
       COUNT(*) AS employees,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS leavers,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM (
    SELECT Attrition,
           NTILE(10) OVER (ORDER BY MonthlyIncome) AS income_decile
    FROM hr
) t
GROUP BY income_decile
ORDER BY income_decile;

-- 23. Create a simple risk score based on tenure, performance, overtime, and work-life balance — 
-- and list the top 50 high-risk employees. 
SELECT EmployeeNumber, Department, JobRole, YearsAtCompany,
       PerformanceRating, OverTime, WorkLifeBalance,
       (CASE WHEN YearsAtCompany < 2 THEN 2 WHEN YearsAtCompany < 5 THEN 1 ELSE 0 END)
     + (CASE WHEN PerformanceRating <= 3 THEN 1 ELSE 0 END)
     + (CASE WHEN OverTime = 'Yes' THEN 2 ELSE 0 END)
     + (CASE WHEN WorkLifeBalance = 1 THEN 2 WHEN WorkLifeBalance = 2 THEN 1 ELSE 0 END) AS risk_score
FROM hr
ORDER BY risk_score DESC, YearsAtCompany ASC
LIMIT 50;

-- 24. Create a summary view showing, for each department and job level: total employees, 
-- number of leavers, attrition rate, and average monthly income.
CREATE VIEW dept_joblevel_summary AS
SELECT Department, JobLevel,
       COUNT(*) AS total_employees,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS leavers,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct,
       ROUND(AVG(MonthlyIncome), 2) AS avg_monthly_income
FROM hr
GROUP BY Department, JobLevel;

-- then query it:
SELECT * FROM dept_joblevel_summary;

