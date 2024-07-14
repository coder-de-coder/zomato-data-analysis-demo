CREATE DATABASE IF NOT EXISTS zomato;
USE zomato;

SET SQL_SAFE_UPDATES = 0;

SELECT @@secure_file_priv;

CREATE TABLE ZomatoDataNew (
    RestaurantID INT,
    RestaurantName VARCHAR(255),
    CountryCode INT,
    City VARCHAR(255),
    Address VARCHAR(255),
    Locality VARCHAR(255),
    LocalityVerbose VARCHAR(255),
    Cuisines VARCHAR(255),
    Currency VARCHAR(100),
    HasTableBooking VARCHAR(10),
    HasOnlineDelivery VARCHAR(10),
    IsDeliveringNow VARCHAR(10),
    SwitchToOrderMenu VARCHAR(10),
    PriceRange INT,
    Votes INT,
    AverageCost VARCHAR(255),
    RatingAggregate FLOAT,
    RatingColor VARCHAR(10),
    RatingText VARCHAR(50)
);

LOAD DATA INFILE '/var/lib/mysql-files/Zomato_Dataset_clean.csv'
INTO TABLE ZomatoDataNew
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(RestaurantID, RestaurantName, CountryCode, City, Address, Locality, LocalityVerbose, Cuisines, Currency, HasTableBooking, HasOnlineDelivery, IsDeliveringNow, SwitchToOrderMenu, PriceRange, Votes, AverageCost, RatingAggregate);

ALTER TABLE ZomatoDataNew MODIFY COLUMN Currency VARCHAR(50);

-- Check Data Types of Table Columns 
USE project;
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ZomatoDataNew';

-- Check for Duplicate Values in RestaurantID
SELECT RestaurantID, COUNT(RestaurantID) 
FROM ZomatoDataNew
GROUP BY RestaurantID
ORDER BY 2 DESC;

-- Create Country Code Table 
CREATE TABLE ZOMATO_COUNTRY (
    COUNTRYCODE INT PRIMARY KEY,
    COUNTRY VARCHAR(50)
);

-- insert data to country code table
INSERT INTO ZOMATO_COUNTRY (COUNTRYCODE, COUNTRY) VALUES
(1, 'India'),
(14, 'Australia'),
(30, 'Brazil'),
(37, 'Canada'),
(94, 'Indonesia'),
(148, 'New Zealand'),
(162, 'Phillipines'),
(166, 'Qatar'),
(184, 'Singapore'),
(189, 'South Africa'),
(191, 'Sri Lanka'),
(208, 'Turkey'),
(214, 'UAE'),
(215, 'United Kingdom'),
(216, 'United States');

-- merge country codes to names
UPDATE ZomatoDataNew A
JOIN ZOMATO_COUNTRY B ON A.CountryCode = B.COUNTRYCODE
SET A.COUNTRY_NAME = B.COUNTRY;



-- sanitize city names
SELECT DISTINCT City 
FROM ZomatoDataNew 
WHERE City LIKE '%?%';

UPDATE ZomatoDataNew 
SET City = REPLACE(City, '?', 'i') 
WHERE City LIKE '%?%';

-- count number of restraunts by city 
SELECT COUNTRY_NAME, CITY, COUNT(City) AS TOTAL_REST 
FROM ZomatoDataNew
GROUP BY COUNTRY_NAME, CITY 
ORDER BY 1, 2, 3 DESC;



























