# WorldBankMetrics

1.Initial check of the Population table in the database to ensure that a CSV file was loaded correctly.

2.Quick manipulation to find the maximum population for every country in any given year.

3.Quick manipulation to find the percentile rank of a given country in relation to other countries for each year.

4.Bringing a Continent to Country CSV table to match countries to continents and checking for discrepancies between World Bank and Github naming of countries.

5.Updating the Continent table with corresponding World Bank names of countries using the UPDATE function in the table.

6.Creating a Common Table Expression (CTE) to temporarily store a table to use and manipulate with other variable tables.

7.Using the CTE in a nested query to join the continent and population table since population has the most complete amount of data.

8.Creating a view as a permanent table called "WorldBankVariables" that can be used for easier data manipulation with all of the World Bank variables compiled.

9.Using the "WorldBankVariables" view in the SELECT statement to retrieve data for multiple variables such as GDP, Population Density, Death Rate, and Electricity. The data is rounded to two decimal places for better readability.

10.Further manipulating the data using various SQL functions such as CASE, COALESCE, and window functions like ROW_NUMBER(), RANK(), and DENSE_RANK() to calculate rankings, differences, and percentage changes.

11.Sorting the final result by Country, Year, and variable values in ascending or descending order as needed.

12.The query also includes comments to provide explanations and annotations for each step of the data manipulation process.
