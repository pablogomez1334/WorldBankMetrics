# WorldBankMetrics

Initial check of the Population table in the database to ensure that a CSV file was loaded correctly.

Quick manipulation to find the maximum population for every country in any given year.

Quick manipulation to find the percentile rank of a given country in relation to other countries for each year.

Bringing a Continent to Country CSV table to match countries to continents and checking for discrepancies between World Bank and Github naming of countries.

Updating the Continent table with corresponding World Bank names of countries using the UPDATE function in the table.

Creating a Common Table Expression (CTE) to temporarily store a table to use and manipulate with other variable tables.

Using the CTE in a nested query to join the continent and population table since population has the most complete amount of data.

Creating a view as a permanent table called "WorldBankVariables" that can be used for easier data manipulation with all of the World Bank variables compiled.

Using the "WorldBankVariables" view in the SELECT statement to retrieve data for multiple variables such as GDP, Population Density, Death Rate, and Electricity. The data is rounded to two decimal places for better readability.

Further manipulating the data using various SQL functions such as CASE, COALESCE, and window functions like ROW_NUMBER(), RANK(), and DENSE_RANK() to calculate rankings, differences, and percentage changes.

Sorting the final result by Country, Year, and variable values in ascending or descending order as needed.

The query also includes comments to provide explanations and annotations for each step of the data manipulation process.
