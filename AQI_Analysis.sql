-- create database
CREATE DATABASE india_aqi_project;
USE india_aqi_project;

DROP TABLE IF EXISTS aqi_data;

-- create table
CREATE TABLE aqi_data (
    date VARCHAR(20),
    state VARCHAR(100),
    area VARCHAR(100),
    number_of_monitoring_stations INT,
    prominent_pollutants VARCHAR(100),
    aqi_value INT,
    air_quality_status VARCHAR(50),
    unit VARCHAR(200)
);

-- load dataset
LOAD DATA LOCAL INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\india_aqi_project\\aqi_data.csv"
INTO TABLE aqi_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SELECT * FROM aqi_data;

-- BASIC DATA UNDERSTANDING
-- 1.Total number of records in dataset
SELECT COUNT(*) AS total_records
FROM aqi_data;

-- 2.Find earliest and latest date in dataset
SELECT 
MIN(date) AS start_date,
MAX(date) AS end_date
FROM aqi_data;

-- 3. Number of states covered in dataset
SELECT COUNT(DISTINCT state) AS total_states
FROM aqi_data;

-- 4.Number of cities in dataset
SELECT COUNT(DISTINCT area) AS total_cities
FROM aqi_data;


-- DATA QUALITY CHECK
-- 5.Check rows where AQI value is missing
SELECT * FROM aqi_data
WHERE aqi_value IS NULL;

-- 6.Find duplicate records
SELECT date, area, COUNT(*)
FROM aqi_data
GROUP BY date, area
HAVING COUNT(*) > 1;


-- AQI DESCRIPTIVE ANALYSIS
-- 7.Average air quality index across all records
SELECT ROUND(AVG(aqi_value),2) AS avg_aqi
FROM aqi_data;

-- 8.Worst pollution level recorded
SELECT MAX(aqi_value) AS max_aqi
FROM aqi_data;


-- CITY LEVEL ANALYSIS
-- 9.Top 10 cities with highest average AQI
SELECT area AS city,
AVG(aqi_value) AS avg_aqi
FROM aqi_data
GROUP BY area
ORDER BY avg_aqi DESC
LIMIT 10;

-- 10.Cities with best air quality
SELECT area,
AVG(aqi_value) AS avg_aqi
FROM aqi_data
GROUP BY area
ORDER BY avg_aqi ASC
LIMIT 10;


-- STATE LEVEL ANALYSIS
-- 11.Average pollution level per state
SELECT state,
AVG(aqi_value) AS avg_aqi
FROM aqi_data
GROUP BY state
ORDER BY avg_aqi DESC;

-- 12.Total monitoring stations available per state
SELECT state,
SUM(number_of_monitoring_stations) AS stations
FROM aqi_data
GROUP BY state
ORDER BY stations DESC;


-- POLLUTANT ANALYSIS
-- 13.Which pollutant appears most frequently
SELECT prominent_pollutants,
COUNT(*) AS frequency
FROM aqi_data
GROUP BY prominent_pollutants
ORDER BY frequency DESC;

-- 14.Average AQI caused by each pollutant
SELECT prominent_pollutants,
AVG(aqi_value) AS avg_aqi
FROM aqi_data
GROUP BY prominent_pollutants
ORDER BY avg_aqi DESC;

-- TIME TREND ANALYSIS
-- 15.AQI trend over time
SELECT date,
AVG(aqi_value) AS avg_aqi
FROM aqi_data
GROUP BY date
ORDER BY date;

-- 16.Monthly pollution trend
SELECT 
YEAR(STR_TO_DATE(date,'%d-%m-%Y')) AS year,
MONTH(STR_TO_DATE(date,'%d-%m-%Y')) AS month,
AVG(aqi_value) AS avg_aqi
FROM aqi_data
GROUP BY year, month
ORDER BY year, month;


-- ADVANCED DATA ANALYST QUERIES
-- 17.Rank states based on pollution level
SELECT state,
AVG(aqi_value) AS avg_aqi,
RANK() OVER (ORDER BY AVG(aqi_value) DESC) AS pollution_rank
FROM aqi_data
GROUP BY state;

-- 18.Identify cities with hazardous air quality
SELECT area,
aqi_value,
air_quality_status
FROM aqi_data
WHERE air_quality_status = 'Hazardous'
ORDER BY aqi_value DESC;

-- 19.Count number of records in each AQI category
SELECT air_quality_status,
COUNT(*) AS total_records
FROM aqi_data
GROUP BY air_quality_status;

-- 20.Find the most polluted city in each state based on average AQI
SELECT state, city, avg_aqi
FROM
(SELECT state,
           area AS city,
           AVG(aqi_value) AS avg_aqi,
           RANK() OVER (PARTITION BY state ORDER BY AVG(aqi_value) DESC) AS rank_num
    FROM aqi_data
    GROUP BY state, area
) ranked_cities
WHERE rank_num = 1;

















