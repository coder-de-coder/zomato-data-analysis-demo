-- rolling count of restraunts in indian cities using window function
SELECT CITY, Locality, COUNT(Locality) AS COUNT_LOCALITY,
SUM(COUNT(Locality)) OVER(PARTITION BY City ORDER BY Locality) AS ROLL_COUNT
FROM ZomatoDataNew
WHERE COUNTRY_NAME = 'INDIA'
GROUP BY Locality, CITY
ORDER BY 1, 2, 3 DESC;

-- City and Locality in India with Maximum Listed Restaurants
WITH CT1 AS (
    SELECT City, Locality, COUNT(RestaurantID) AS REST_COUNT
    FROM ZomatoDataNew
    WHERE COUNTRY_NAME = 'INDIA'
    GROUP BY City, Locality
)
SELECT Locality, REST_COUNT 
FROM CT1 
WHERE REST_COUNT = (SELECT MAX(REST_COUNT) FROM CT1);




-- Find Most Popular Cuisine in Indian Cities
-- Create a view to split cuisines into separate rows
CREATE OR REPLACE VIEW VF AS
SELECT COUNTRY_NAME, City, Locality, SUBSTRING_INDEX(SUBSTRING_INDEX(Cuisines, '|', numbers.n), '|', -1) AS Cuisines
FROM ZomatoDataNew
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
    UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
) numbers
ON CHAR_LENGTH(Cuisines) - CHAR_LENGTH(REPLACE(Cuisines, '|', '')) >= numbers.n - 1
WHERE COUNTRY_NAME = 'INDIA';

-- Common Table Expressions (CTE) to find the city with the maximum number of restaurants
WITH CT1 AS (
    SELECT CITY, COUNT(CITY) AS CITY_COUNT
    FROM ZomatoDataNew
    WHERE COUNTRY_NAME = 'INDIA'
    GROUP BY CITY
),
CT2 AS (
    SELECT CITY, CITY_COUNT 
    FROM CT1 
    WHERE CITY_COUNT = (SELECT MAX(CITY_COUNT) FROM CT1)
)
-- Main query to count cuisines in the city with the highest number of restaurants
SELECT A.Cuisines, COUNT(A.Cuisines) AS Cuisines_Count
FROM VF A
JOIN CT2 B
ON A.City = B.City
GROUP BY A.Cuisines
ORDER BY Cuisines_Count DESC;


-- Percentage of Restaurants in All Countries
CREATE OR REPLACE VIEW TotalRestaurantCount AS
SELECT COUNT(*) AS TotalRestaurants
FROM ZomatoDataNew;

SELECT 
    COUNTRY_NAME, 
    COUNT(RestaurantID) AS RestaurantCount,
    ROUND((COUNT(RestaurantID) / (SELECT TotalRestaurants FROM TotalRestaurantCount)) * 100, 2) AS Percentage
FROM ZomatoDataNew
GROUP BY COUNTRY_NAME
ORDER BY Percentage DESC;



