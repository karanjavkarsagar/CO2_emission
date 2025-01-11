#Task 1
#Retrieve the top 10 countries with the highest emissions in the last decade.
SELECT country, 
       SUM(total_co2_emission_including_luc) AS total_emissions
FROM co2_emissions
WHERE year >= (SELECT MAX(year) - 10 FROM co2_emissions) AND
country NOT IN ('World', 'Asia', 'European Union (27)','Africa', 'Europe', 'North America', 'Lower-middle-income countries','South America', 'Oceania','Upper-middle-income countries','High-income countries')
GROUP BY country
ORDER BY total_emissions DESC
 LIMIT 10;
 
 #Task 2
 #Calculate year-over-year changes in emissions for a selected sector
 
 SELECT 
    country,
    year,
    coal_co2,
    gas_co2,
    oil_co2,
    cement_co2,
    flaring_co2,
    land_use_change_co2,
    other_industry_co2,
    
    
    -- Year-over-year changes for each sector
    LAG(coal_co2) OVER (PARTITION BY country ORDER BY year) AS previous_year_coal_co2,
    ((coal_co2 - LAG(coal_co2) OVER (PARTITION BY country ORDER BY year)) / LAG(coal_co2) OVER (PARTITION BY country ORDER BY year)) * 100 AS yoy_change_coal_co2,
    
    LAG(gas_co2) OVER (PARTITION BY country ORDER BY year) AS previous_year_gas_co2,
    ((gas_co2 - LAG(gas_co2) OVER (PARTITION BY country ORDER BY year)) / LAG(gas_co2) OVER (PARTITION BY country ORDER BY year)) * 100 AS yoy_change_gas_co2,
    
    LAG(oil_co2) OVER (PARTITION BY country ORDER BY year) AS previous_year_oil_co2,
    ((oil_co2 - LAG(oil_co2) OVER (PARTITION BY country ORDER BY year)) / LAG(oil_co2) OVER (PARTITION BY country ORDER BY year)) * 100 AS yoy_change_oil_co2,
    
    LAG(cement_co2) OVER (PARTITION BY country ORDER BY year) AS previous_year_cement_co2,
    ((cement_co2 - LAG(cement_co2) OVER (PARTITION BY country ORDER BY year)) / LAG(cement_co2) OVER (PARTITION BY country ORDER BY year)) * 100 AS yoy_change_cement_co2,
    
    LAG(flaring_co2) OVER (PARTITION BY country ORDER BY year) AS previous_year_flaring_co2,
    ((flaring_co2 - LAG(flaring_co2) OVER (PARTITION BY country ORDER BY year)) / LAG(flaring_co2) OVER (PARTITION BY country ORDER BY year)) * 100 AS yoy_change_flaring_co2,
    
    LAG(land_use_change_co2) OVER (PARTITION BY country ORDER BY year) AS previous_year_land_use_change_co2,
    ((land_use_change_co2 - LAG(land_use_change_co2) OVER (PARTITION BY country ORDER BY year)) / LAG(land_use_change_co2) OVER (PARTITION BY country ORDER BY year)) * 100 AS yoy_change_land_use_change_co2,
    
    LAG(other_industry_co2) OVER (PARTITION BY country ORDER BY year) AS previous_year_other_industry_co2,
    ((other_industry_co2 - LAG(other_industry_co2) OVER (PARTITION BY country ORDER BY year)) / LAG(other_industry_co2) OVER (PARTITION BY country ORDER BY year)) * 100 AS yoy_change_other_industry_co2
    

FROM 
    co2_emissions
WHERE 
    coal_co2 IS NOT NULL 
    OR gas_co2 IS NOT NULL 
    OR oil_co2 IS NOT NULL 
    OR cement_co2 IS NOT NULL 
    OR flaring_co2 IS NOT NULL 	
    OR land_use_change_co2 IS NOT NULL 
    OR other_industry_co2 IS NOT NULL 
  
ORDER BY 
    country, year;
    
    #Task 3
    #Identify countries with the most significant reduction in emissions.
    
    WITH filtered_emissions AS (
    SELECT 
        country,
        year,
        total_co2_emission_including_luc
    FROM 
        co2_emissions
    WHERE 
        total_co2_emission_including_luc IS NOT NULL
        AND year >= (SELECT MAX(year) - 25 FROM co2_emissions)  -- Focus on the last 25 years
        AND country NOT IN ('World', 'Asia', 'European Union (27)', 'Africa', 'Europe', 
                            'North America', 'Lower-middle-income countries', 'South America', 
                            'Oceania', 'Upper-middle-income countries', 'High-income countries')  -- Exclude specified countries
)
SELECT 
    country,
    MIN(year) AS first_year,  
    MAX(year) AS last_year,   
    MIN(total_co2_emission_including_luc) AS first_year_emissions, 
    MAX(total_co2_emission_including_luc) AS last_year_emissions,   
    ((MAX(total_co2_emission_including_luc) - MIN(total_co2_emission_including_luc)) / MIN(total_co2_emission_including_luc)) * 100 AS total_yoy_change_percentage
FROM 
    filtered_emissions
GROUP BY 
    country
HAVING 
    MIN(total_co2_emission_including_luc) > 0  
    AND MAX(total_co2_emission_including_luc) > 0  
ORDER BY 
    total_yoy_change_percentage ASC  -- 
LIMIT 20;  -- 

    #Task 4
    #Create a summary table of emissions by region and sector.
SELECT 
    region,
    SUM(coal_co2) AS total_coal_emissions,
    SUM(gas_co2) AS total_gas_emissions,
    SUM(oil_co2) AS total_oil_emissions,
    SUM(cement_co2) AS total_cement_emissions,
    SUM(flaring_co2) AS total_flaring_emissions,
    SUM(land_use_change_co2) AS total_land_use_change_emissions,
    SUM(other_industry_co2) AS total_other_industry_emissions,
    SUM(total_co2_emission_including_luc) AS total_emissions
FROM 
    co2_emissions
WHERE 
    region IS NOT NULL  -- Filter out rows where region is missing
   
GROUP BY 
    region
ORDER BY 
    total_emissions DESC;  -- Order by total emissions in descending order

