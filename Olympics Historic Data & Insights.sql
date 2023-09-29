SELECT TOP (1000) [ID]
      ,[Name]
      ,[Sex]
      ,[Age]
      ,[Height]
      ,[Weight]
      ,[Team]
      ,[Country]
      ,[Games]
      ,[Year]
      ,[Season]
      ,[City]
      ,[Sport]
      ,[Event]
      ,[Medal]
  FROM [PortfolioProject].[dbo].['Olympics History$']

  -- First lets change the Medal column to reflect Null values instead of 'NA'
  UPDATE [PortfolioProject].[dbo].['Olympics History$']
SET Medal = NULL
WHERE Medal = 'NA';



--- COUNTRY INSIGHTS

  -- Find which countries have had the most representation over the years Limit 5.
  WITH Representation AS (
	SELECT Country, COUNT(*) As Number_of_Athletes
	FROM [PortfolioProject].[dbo].['Olympics History$']
	GROUP BY Country
)
SELECT TOP(5) Country, Number_of_Athletes, RANK() OVER(ORDER BY Number_of_Athletes Desc) AS Ranking 
FROM Representation


-- Find percentage of total athletes each country makes up for. 
SELECT 
    C1.Country, 
    COUNT(*) AS Athlete_make_up,
    100.00 * COUNT(C1.Country) / SUM(COUNT(*)) OVER() AS pct_of_whole
FROM 
    [PortfolioProject].[dbo].['Olympics History$'] AS C1
GROUP BY 
    C1.Country
ORDER BY 
    pct_of_whole DESC;


-- Find how many medals of each type the each country has. 
SELECT Country, Medal, COUNT(*) As Medals_Earned
FROM [PortfolioProject].[dbo].['Olympics History$']
WHERE Medal IS NOT NUll
GROUP BY ROLLUP(Country, Medal) 
ORDER BY country
 

-- Which 10 Countries have wont the most Gold Medals? 
SELECT Top(10) Country, Medal, COUNT(*) As LiquidGoldCount
FROM [PortfolioProject].[dbo].['Olympics History$']
WHERE Medal = 'Gold'
GROUP BY Country, Medal
ORDER BY LiquidGoldCount Desc;



--- MALE AND FEMALE REPRESENTATION

-- Find which countries have had the most representation over the years partitioned by sex.
  WITH Representation AS (
	SELECT Country, Sex, COUNT(*) As Number_of_Athletes
	FROM [PortfolioProject].[dbo].['Olympics History$']
	GROUP BY Country, Sex
)
SELECT Country, Sex, Number_of_Athletes, RANK() OVER(PARTITION BY Sex ORDER BY Number_of_Athletes Desc) AS Ranking
FROM Representation


-- How has representation of male and female athletes changed over the years?
-- Give a perecentage of the gender make up for each olympic year. 
SELECT 
    t1.Year, 
    t1.Sex, 
    COUNT(t1.Sex) AS Gender_Make_Up,
    100.0 * COUNT(t1.Sex) / t2.Total_Count AS Percentage
FROM 
    [PortfolioProject].[dbo].['Olympics History$'] t1
JOIN (
    SELECT Year, COUNT(Sex) AS Total_Count
    FROM [PortfolioProject].[dbo].['Olympics History$']
    GROUP BY Year
) t2 ON t1.Year = t2.Year
GROUP BY t1.Year, t1.Sex, t2.Total_Count
ORDER BY t1.Year, t1.Sex;



--- AGE INSIGHTS

-- Historically, what is the probability of someone going to the olympics based purely on their age group? 
SELECT 
    CASE 
        WHEN Age <= 15  THEN '15 & Under' 
        WHEN Age <= 20 THEN '16-20' 
        WHEN Age <= 25 THEN '21-25'
		WHEN Age <= 30 THEN '26-30' 
        WHEN Age <= 35 THEN '31-35'
		WHEN Age <= 40 THEN '36-40'
		WHEN Age <= 45 THEN '41-45'
		WHEN Age <= 50 THEN '46-50'
		WHEN Age <= 55 THEN '51-55'
        ELSE 'Over 55'
    END AS Age_Make_Up,
    COUNT(*) AS Count, 
	 CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM [PortfolioProject].[dbo].['Olympics History$']) AS DECIMAL(10, 2)) AS percentage_of_total
FROM [PortfolioProject].[dbo].['Olympics History$']
GROUP BY  
  CASE 
        WHEN Age <= 15  THEN '15 & Under' 
        WHEN Age <= 20 THEN '16-20' 
        WHEN Age <= 25 THEN '21-25'
		WHEN Age <= 30 THEN '26-30' 
        WHEN Age <= 35 THEN '31-35'
		WHEN Age <= 40 THEN '36-40'
		WHEN Age <= 45 THEN '41-45'
		WHEN Age <= 50 THEN '46-50'
		WHEN Age <= 55 THEN '51-55'
        ELSE 'Over 55'
    END
ORDER BY percentage_of_total Desc;


-- What ages made up the majority of the olympics in 2016? 

SELECT Age1.Age, Age1.Year, COUNT(*) AS Age_Make_Up_Count,
	100.0 * COUNT(Age1.Age)/ Age2.total_count As Percentage_of_Whole
FROM [PortfolioProject].[dbo].['Olympics History$'] AS Age1
JOIN (
SELECT Age, COUNT(*) AS total_count
FROM [PortfolioProject].[dbo].['Olympics History$']
GROUP BY Age
) AS Age2
On Age1.Age = Age2.Age
WHERE Age1.Year = '2016'
GROUP BY Age1.Age, Age1.Year, Age2.total_count
ORDER BY Percentage_of_Whole Desc;


-- Whats been the average age of athletes each year? 
SELECT Year, AVG(Age) As Years_Age
FROM [PortfolioProject].[dbo].['Olympics History$']
GROUP BY Year
ORDER BY Year 



--- ATHLETE INSIGHTS 

-- It is believed that athletes have gotten bigger and stronger over the years. We'll calculate a 3 olympic years moving average to find if theres a trend.
WITH HeightStats AS (
	SELECT Year, Sex, AVG(Height) As Athletes_height, AVG(Weight) AS Athletes_weight
	FROM [PortfolioProject].[dbo].['Olympics History$']
	WHERE Height IS NOT NULL AND Weight IS NOT NULL
	GROUP BY Year, Sex
)
SELECT Year, Sex,
AVG(Athletes_height) OVER(Partition by Sex ORDER BY Year
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Height_MA,
AVG(Athletes_weight) OVER (Partition by Sex Order by year
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Weight_MA 
FROM HeightStats
ORDER BY Sex, Year


-- Which athletes have won the most medals?
SELECT TOP 10 Name, Country, Sport, COUNT(*) As MedalsEarned
FROM [PortfolioProject].[dbo].['Olympics History$']
WHERE Medal IS NOT NULL
GROUP BY Name, Country, Sport
ORDER BY MedalsEarned Desc;

--OTHER INSIGHTS 

-- Which years where the most popular and the least? Could that speak to the state of the world at that time? 
SELECT Year, Season, COUNT(*) As number_of_attendents
FROM [PortfolioProject].[dbo].['Olympics History$']
GROUP BY CUBE(Year, Season)


-- Which sports have been the most popular each year over the years? Has there been a change in the last 100 years? 
SELECT Year, Sport, Most_Popular_Sports, Ranking
FROM (
    SELECT Year, Sport, Most_Popular_Sports, 
           RANK() OVER(PARTITION BY Year ORDER BY Most_Popular_Sports DESC) AS Ranking
    FROM (
        SELECT Year, Sport, COUNT(*) AS Most_Popular_Sports
        FROM [PortfolioProject].[dbo].['Olympics History$']
        GROUP BY Year, Sport
    ) AS Most_Popular
) AS RankedSports
WHERE Ranking = 1;


