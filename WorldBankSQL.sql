-- Author: Pablo Gomez
-- Date: 2/21/2023
-- Topic: SQL Data manipulation for Multiple variables measured by the World Bank, to further use in data vizulization analysis
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Initial Check of Population table in the database to make sure csv file was loaded correctly
select *
from WorldBank_stats..WB_Population$;
--Quick naipulation to find max population for every country in any given year 
select Country_Name, max(Population) as Max_Population
from WorldBank_stats..WB_Population$
group by Country_Name
order by 2 desc;
-- Quick manipulation finding the percentile rank of a given country in relation to other countries for each year
select Country_Name, Year, Percent_Rank() over (partition by year order by Population) as Percentile
from WorldBank_stats..WB_Population$
order by 1,2;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Bringing a Continent to country csv table to match country to continent
-- Checking the discrepencies between World Bank and Github naming of countries
-- For example, 'Turkey' official name is 'Turkiye', checking other official names using following query
select *
from WorldBank_stats..Continent_Country$ as Continent
left join WorldBank_stats..WB_Population$ as Population 
	on Continent.Country = Population.Country_Name
where Country_Name is null
order by 2;

--Update Continent table with corresponding World Bank names of country using Update function in table
UPDATE WorldBank_stats..Continent_Country$
SET country = 
  CASE
    WHEN country = 'Bahamas' THEN 'Bahamas, The'
    WHEN country = 'Brunei' THEN 'Brunei Darussalam'
	WHEN country = 'Burkina' THEN 'Burkina Faso'
	WHEN country = 'Burma (Myanmar)' Then 'Myanmar'
	WHEN country = 'Cape Verde' THEN 'Cabo Verde'
	WHEN country = 'Congo, Democratic Republic of' THEN 'Congo, Dem. Rep.'
	WHEN country = 'Congo' THEN 'Congo, Rep.'
	WHEN country = 'CZ' THEN 'Czechia'
	WHEN country = 'East Timor' THEN 'Timor-Leste'
	WHEN country = 'Egypt' THEN 'Egypt, Arab Rep.'
	WHEN country = 'Gambia' THEN 'Gambia, The'
	WHEN country = 'Iran' THEN 'Iran, Islamic Rep.' 
	WHEN country = 'Ivory Coast' THEN 'Cote d''Ivoire'
	WHEN country = 'Korea, North' then 'Korea, Dem. People''s Rep.'
	WHEN country = 'Korea, South' then 'Korea, Rep.'
	When country = 'Kyrgyzstan' then 'Kyrgyz Republic'
	When country = 'Laos' then 'Lao PDR'
	When country = 'Macedonia' then 'North Macedonia'
	When country = 'Micronesia' then 'Micronesia, Fed. Sts.'
	When country = 'Saint Kitts and Nevis' then 'St. Kitts and Nevis'
	When country = 'Saint Lucia' then 'St. Lucia'
	When country = 'Saint Vincent and the Grenadines' then 'St. Vincent and the Grenadines'
	When country = 'Slovakia' then 'Slovak Republic'
	When country = 'Swaziland' then 'Eswatini'
	When country = 'Syria' then 'Syrian Arab Republic'
	When country = 'Turkey' then 'Turkiye'
	When country = 'US' then 'United States'
	When country = 'Venezuela' then 'Venezuela, RB'
	When country = 'Yemen' then 'Yemen, Rep.'
    ELSE Null
  END
WHERE country IN ('Bahamas', 'Brunei','Burkina','Burma (Myanmar)','Cape Verde','Congo','Congo, Democratic Republic of','CZ','East Timor','Egypt','Gambia','Iran',
'Ivory Coast','Korea, North','Korea, South','Kyrgyzstan','Laos','Macedonia','Micronesia','Saint Kitts and Nevis','Saint Lucia','Saint Vincent and the Grenadines',
'Slovakia','Swaziland','Syria','Turkey','US','Vatican City','Venezuela','Yemen');
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- First create a CTE (Common Table Expression) to temporarly store a table to use and manipulate with the other variable tables
-- Using the CTE in a certain way as a nested query first joining the continent and population table since population has most complete amount of data
-- In addition we create a view as a permanent table that that we can use for easier data manipulation with all of the World Bank variables compiled
-- We use Create View command with the corresponding query 
Create View WorldBankVariables as
with continent_merge as(select *
from WorldBank_stats.dbo.Continent_Country$ as continents
join WorldBank_stats.dbo.WB_Population$ as population 
on continents.Country = population.Country_Name)
-- Use CTE in the from statement with the corresponding columns we want showed in the query table
select Continent
, Country
, continent_merge.Country_Code
, continent_merge.Year
, continent_merge.Population
, round(gdp.GDP,2) as GDP
, round(pop_density.Population_Density,2) as Pop_Density
, round(death_rate.Death_Rate,2) as Death_Rate
, round(elec.Electricity,2) as Electricity
from continent_merge
left join WorldBank_stats.dbo.GDP$ as gdp
on continent_merge.Country = gdp.Country_Name and continent_merge.Year = gdp.Year
left join WorldBank_stats.dbo.Population_Density$ as pop_density
on continent_merge.Country = pop_density.Country_Name and continent_merge.Year = pop_density.Year
left join WorldBank_stats.dbo.Death_Rate$ as death_rate
on continent_merge.Country = death_rate.Country_Name and continent_merge.Year = death_rate.Year
left join WorldBank_stats.dbo.Electricity$ as elec
on continent_merge.Country = elec.Country_Name and continent_merge.Year = elec.Year;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Once View table is created, we observe it and manipulate
-- First we check out the population of each given continent for every year
SELECT Continent, Year, round(avg(Population),0) as Average_Population
FROM WorldBank_stats.dbo.WorldBankVariables
group by Continent, Year
order by 2,3 desc;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- First we will look at the percentage change for each variable in each country for year
-- First we find the previous year value using the lag() function partitioning by country 
Create View PercentChange as
with previous_year as (Select Continent
, Country
, Year
, Population
, GDP
, Pop_Density
, Death_Rate
, Electricity
, LAG(Population) Over(Partition by Country order by year) as Previous_population
, LAG(GDP) Over (Partition by Country order by year) as Previous_gdp
, LAG(Pop_Density) Over (Partition by Country order by year) as Previous_pop_density
, LAG(Death_Rate) Over (Partition by Country order by year) as Previous_death_rate
, LAG(Electricity) Over (Partition by Country order by year) as Previous_electricity
From WorldBank_stats.dbo.WorldBankVariables)
-- Then placing the previous query as a CTE, we manipulate data to calculate the percent change
-- We calculate by sunctracting the current year value from the previous year and dividing it by last year's value and ultimately multiplying by 100 to get the number in a percentage form
-- We will place the whole query in a another view table to further extract for data visualization
select Continent
, Country
, Year
, Population
, GDP
, Pop_Density
, Death_Rate
, Electricity
, round(((Population-Previous_population)/Previous_population)*100,2) as Population_Change
, round(((GDP-Previous_gdp)/Previous_gdp)*100,2) as GDP_Change
, round(((Pop_Density-Previous_pop_density)/Previous_pop_density)*100,2) as Population_Density_Change
, round(((Death_Rate-Previous_death_rate)/Previous_death_rate)*100,2) as Death_Rate_Change
, round(((Electricity-Previous_electricity)/Previous_electricity)*100,2) as Electricity_Change
from previous_year;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Now we will look to calculate the percentile rank of eack country from one another for each given year
-- Using the Window function of Percent Rank we find the perentile rank for each country given the respective variable
-- We will store this query in a View table for ater data visulization
Create View PercentileRank as
Select Continent
, Country
, Year
, Population
, GDP
, Pop_Density
, Death_Rate
, Electricity
, Round(PERCENT_RANK() Over(partition by year order by Population)*100,2) as Population_Rank
, Round(PERCENT_RANK() Over(partition by year order by GDP)*100,2) as GDP_Rank
, Round(PERCENT_RANK() Over(partition by year order by Pop_Density)*100,2) as Population_Density_Rank
, Round(PERCENT_RANK() Over(partition by year order by Death_Rate)*100,2) as Death_Rate_Rank
, Round(PERCENT_RANK() Over(partition by year order by Electricity)*100,2) as Electricity_Rank
from WorldBank_stats.dbo.WorldBankVariables;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- We are going to distinguish by eras or decades using the Case function
-- We will save the eras table into another View Table query
Create View Eras as 
select *,
Case
	When Year>=1960 and Year<=1969 Then '1960''s'
	When Year>=1970 and Year<=1979 Then '1970''s'
	When Year>=1980 and Year<=1989 Then '1980''s'
	When Year>=1990 and Year<=1999 Then '1990''s'
	When Year>=2000 and Year<=2009 Then '2000''s'
	When Year>=2010 and Year<=2019 Then '2010''s'
	Else 'N/A' end as Era 
from WorldBank_stats.dbo.WorldBankVariables;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Using the eras variable we can calculate many trends for that of what happened during the corresponding eras
-- We use a nested loop to query up the relevant information by grouping sum of each continent
-- Then selecting the relevant information of the nested query group by era
with Era_Continent_Population as (select Continent, Era, round(AVG(Total_Population),0) as Average_Population
from (select Continent, Year, sum(Population) as Total_Population,Era
from WorldBank_stats.dbo.Eras
group by Continent , Year, Era) as temp
where Era != 'N/A'
group by Continent, Era)
-- Using the Query from before we can find the Era by Era change in percentage
-- We can see using the following Query by use CTE from the previous Query the Percentage growth of population for every given era
select Continent, Era, Average_Population, round((Average_Population-Last_Decade_Population)/Last_Decade_Population*100,2) as Average_Percent_Change
from(
select *, lag(Average_Population) Over (partition by Continent order by Era asc) as Last_Decade_Population
from Era_Continent_Population) as temp2
where Last_Decade_Population is not null
order by 2,4;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- We can merge multiple view tables into another one using the Join function
-- Create another view table to put in order all variables and select all specific data
Create View MergedVariables as 
Select eras.*
, pc.Population_Change
, pc.GDP_Change
, pc.Population_Density_Change
, pc.Death_Rate_Change
, pc.Electricity_Change
, pr.Population_Rank
, pr.GDP_Rank
, pr.Population_Density_Rank
, pr.Death_Rate_Rank
, pr.Electricity_Rank
From WorldBank_stats.dbo.Eras as eras
inner join WorldBank_stats.dbo.PercentChange as pc
	on eras.Country = pc.Country 
	and eras.Year = pc.Year
inner join WorldBank_stats.dbo.PercentileRank as pr
	on eras.Country = pr.Country
	and eras.Year = pr.Year;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lets first try to find the 10 highest economic drops in the dataset by seeing the largest drop in GDP percentage
select top 10 Country, Year, GDP_Change
from WorldBank_stats.dbo.MergedVariables
where GDP_Change is not null
order by GDP_Change asc
-- With the query we see the top ten economic crashes over the past 60 years
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Lets look at the top 15 countries in Asia in terms of GDP per capita in 2015
select top 15 Country, GDP
from WorldBank_stats.dbo.MergedVariables
where Continent = 'Asia' and Year = 2015
order by 2 desc
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lets now look at the top GDP per capita country in each continent in 2019
select Continent, Country, GDP
from(
select Continent, Country, GDP, rank() over (partition by continent order by GDP desc) as rank_continent
from WorldBank_stats.dbo.MergedVariables
where year = 2019 and GDP is not null) as temp
where rank_continent = 1
order by 3 desc
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lets now look at the third quartile in countries in population density.
-- Statistically this is percentile of between 50-75
-- We will look into the year of 2017 to see which countries fall in that range
with second_Quantile as (select Continent, Country, Pop_Density
from(
select Continent, Country, Pop_Density, NTILE(4) over (order by Pop_Density desc) as Quantile_Rank
from WorldBank_stats.dbo.MergedVariables
where year = 2017 and Pop_Density is not null) as temp
where Quantile_Rank = 2)
-- Then using the 2nd quantile of population density, we see how many countries in respective continent fall in that
select Continent, COUNT(*) as Num_of_Countries
from second_Quantile
group by Continent
order by 2 desc;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lets look at string manipulation of countries
-- First see how much letters on average are in the name of countries
with Country_Letters as(
select distinct Country, LEN(replace(replace(replace(Country, ' ',''),',',''),'.','')) as Number_of_letters
from WorldBank_stats.dbo.MergedVariables)
-- Now we look at the average number of letters and find the countries that match that number of letters
select *
from Country_Letters
Where Number_of_letters = (Select AVG(Number_of_letters)
from Country_Letters)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
