CREATE DATABASE CAPSTONE_PROJECT;
USE CAPSTONE_PROJECT;
SELECT * FROM comprehensive_mutual_funds_data;
-- scheme_name, min_sip, min_lumpsum,expense_ratio, fund_size_cr, fund_age_yr, fund_manager, sortino , alpha, sd, risk_level, 
-- amc_name, rating,  category, sub_category, returns_1yr, returns_3yr, returns_5yr
SELECT * FROM Users;
-- UserID, Age, Gender, Email, MobileNumber, City, Country, Occupation, AnnualIncome, InvestmentAmount, InvestmentDuration, RiskTolerance, FundType, DateOfJoining,
-- Matured Amount
   
-- User Analysis 

-- Risk Wise Amount Invested
select RiskTolerance, sum(InvestmentAmount) as Total_Investment from Users
group by RiskTolerance;

-- Total Investment By Fund Type

select FundType, sum(InvestmentAmount) as Total_Investment from Users
group by FundType;

-- Duration Wise  Amount Invested vs Amount Matured 

select  sum(InvestmentAmount) as Invested_amt, sum(Matured_Amount) as Matured_Amount from Users
group by InvestmentDuration;

-- ROI vs Investment by Duration
SELECT FundType, InvestmentDuration,SUM(InvestmentAmount) AS Total_Investment, SUM(Matured_Amount) AS Total_Matured_Amount, 
(SUM(Matured_Amount) - SUM(InvestmentAmount)) AS ROI FROM Users
GROUP BY FundType,InvestmentDuration;

-- Invested Amount vs Matured Amount by occupation
select occupation, sum(InvestmentAmount) as Invested_amt, sum(Matured_Amount) as Matured_Amount from Users
group by occupation;

-- Average Duration of Investment 
select avg(InvestmentDuration) as Avg_Invesment_Duration from Users; 

-- Average Investment In diferent Funds
select FundType, Avg(InvestmentAmount) as Avg_Investment from Users
group by FundType;
 
-- Showing Month on Month Change and Percentage Change 
SELECT 
    Name, 
    FundType, 
    SUM(InvestmentAmount) AS TotalInvestment, 
    SUM(Matured_Amount) AS TotalMaturedAmount, 
    (SUM(Matured_Amount) - SUM(InvestmentAmount)) AS MOM, 
    round(((SUM(Matured_Amount) - SUM(InvestmentAmount)) / SUM(InvestmentAmount)) * (1 / SUM(InvestmentDuration)) * 100,2) AS MOM_Percent,
    (SUM(Matured_Amount) - SUM(InvestmentAmount)) AS ROI, 
    ((SUM(Matured_Amount) - SUM(InvestmentAmount)) / SUM(InvestmentAmount)) * 100 AS ROI_Percent
FROM 
    Users
GROUP BY 
    Name, 
    FundType;

-- SORTINO Ratio Analysis 

-- scheme_name, min_sip, min_lumpsum,expense_ratio, fund_size_cr, fund_age_yr, fund_manager, sortino , alpha, sd, risk_level, 
-- amc_name, rating,  category, sub_category, returns_1yr, returns_3yr, returns_5yr

-- Minimum SIP by Rating and Top N sortino  
select sum(min_sip) as SIP, sortino, rating from comprehensive_mutual_funds_data 
group by rating, sortino 
order by sortino desc;

-- Fund Size by Category and Top N SORTINO 
SELECT SUM(fund_size_cr) AS Fund_Size, sortino, category
FROM comprehensive_mutual_funds_data
GROUP BY category, sortino
ORDER BY Fund_Size DESC;

-- Minimum Lumpsum by Category and Top N SORTINO 
SELECT SUM(min_lumpsum) AS min_lumpsum, sortino, category
FROM comprehensive_mutual_funds_data
GROUP BY category, sortino
ORDER BY min_lumpsum DESC;

-- Returns by Category and TOP N SORTINO
SELECT 
    SUM(fund_size_cr * (1 + returns_1yr / 100)) AS Returns_1YR,
    SUM(fund_size_cr * (1 + returns_3yr / 100)) AS Returns_3YR,
    SUM(fund_size_cr * (1 + returns_5yr / 100)) AS Returns_5YR,
    category,
    sortino
FROM comprehensive_mutual_funds_data
GROUP BY category, sortino, returns_1yr, returns_3yr, returns_5yr
ORDER BY Returns_1YR DESC, Returns_3YR DESC, Returns_5YR DESC;

-- Alpha & Beta Analysis 

-- Minimum SIP & Fund Size by Sub Category and TOP N BETA

Select sum(min_sip) as MIN_SIP, sub_category , beta, sum(fund_size_cr) as fund_size from comprehensive_mutual_funds_data
group by sub_category, beta
order by MIN_SIP desc, fund_size desc;

-- Minimum lumpsum Category and TOP N BETA

SELECT SUM(min_lumpsum) AS Lumpsum, category, beta 
FROM comprehensive_mutual_funds_data
GROUP BY category, beta
ORDER BY Lumpsum DESC;

-- Minimum SIP & Fund Size by  Category and TOP N ALPHA

Select sum(min_sip) as MIN_SIP, category , alpha, sum(fund_size_cr) as fund_size from comprehensive_mutual_funds_data
group by category, alpha
order by MIN_SIP desc, fund_size desc;

-- Minimum lumpsum Category and TOP N ALPHA

SELECT SUM(min_lumpsum) AS Lumpsum, category, alpha 
FROM comprehensive_mutual_funds_data
GROUP BY category, alpha
ORDER BY Lumpsum DESC;

-- Standard Deviation Analysis 

-- Fund by Risk Level and Standard Deviation

-- scheme_name, min_sip, min_lumpsum,expense_ratio, fund_size_cr, fund_age_yr, fund_manager, sortino , alpha, sd, risk_level, 
-- amc_name, rating,  category, sub_category, returns_1yr, returns_3yr, returns_5yr
 select sum(fund_size_cr) as Fund_Size, sd, risk_level from comprehensive_mutual_funds_data
 group by sd, risk_level
 order by Fund_Size Desc;
 
 -- Minimum Lumpsum and SIP by Category and SD
 select sum(min_lumpsum) as Lumpsum, sd, sum(min_sip) as SIP from comprehensive_mutual_funds_data
 group by sd 
 order by Lumpsum Desc,SIP desc;
 
 -- Returns in 1,3,5 by category and SD
 SELECT 
    SUM(fund_size_cr * (1 + returns_1yr / 100)) AS Returns_1YR,
    SUM(fund_size_cr * (1 + returns_3yr / 100)) AS Returns_3YR,
    SUM(fund_size_cr * (1 + returns_5yr / 100)) AS Returns_5YR,
    category,
    sd
FROM comprehensive_mutual_funds_data
GROUP BY category, sd, returns_1yr, returns_3yr, returns_5yr
ORDER BY Returns_1YR DESC, Returns_3YR DESC, Returns_5YR DESC;

-- Expense Ratio Analysis
-- Returns in 1,3,5 Years by Sub_Category and top N Expense Ratio 
 SELECT 
    SUM(fund_size_cr * (1 + returns_1yr / 100)) AS Returns_1YR,
    SUM(fund_size_cr * (1 + returns_3yr / 100)) AS Returns_3YR,
    SUM(fund_size_cr * (1 + returns_5yr / 100)) AS Returns_5YR,
    sub_category,
    expense_ratio
FROM comprehensive_mutual_funds_data
GROUP BY sub_category, expense_ratio, returns_1yr, returns_3yr, returns_5yr
ORDER BY Returns_1YR DESC, Returns_3YR DESC, Returns_5YR DESC;
 
-- Fund Size by Sub_Category and Top N Expense Ratio 
select sum(fund_size_cr) as Fund_Size, sub_category, expense_ratio from comprehensive_mutual_funds_data
group by sub_category, expense_ratio
order by Fund_Size;

-- Minimum Lumpsum and SIP by expense ratio and risk level
select sum(min_lumpsum) as lumpsum, sum(min_sip) as SIP, expense_ratio, risk_level from comprehensive_mutual_funds_data
group by  expense_ratio, risk_level
order by lumpsum desc, SIP desc;

-- 


