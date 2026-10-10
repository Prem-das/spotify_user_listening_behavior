
-- 1. Listening Behavior Over Time
-- Total Listening hours by Month 

SELECT 
DATENAME(MONTH,CAST(ts AS DATETIME2)) AS listening_month,
ROUND(SUM(hours_played),2) AS hrs
FROM spotify_ps_dataset
GROUP BY DATENAME(MONTH,CAST(ts AS DATETIME2))
ORDER BY hrs 

-- Average Daily listening time 

SELECT 
COUNT(DISTINCT CAST(ts AS date)) AS total_active_days,
ROUND(SUM(hours_played),2) AS hrs,
ROUND(SUM(hours_played)/ COUNT(DISTINCT CAST(ts AS DATE)),2) AS avg_hours_per_day
FROM spotify_ps_dataset

-- Considering everyday

WITH calendar_days AS(
	SELECT 
	DATEDIFF(DAY, MIN(CAST(ts AS date)), MAX(CAST(ts AS date))) + 1 AS total_calendar_days,
	ROUND(SUM(hours_played),2) AS hrs
	FROM spotify_ps_dataset
)
SELECT 
	ROUND(hrs/total_calendar_days,2) as avg_hrs_per_day
FROM calendar_days

-- Most active day of the week 

SELECT 
	DATENAME(WEEKDAY, CAST(ts AS datetime2)) AS day_of_week,
	COUNT(DISTINCT CAST(ts AS date)) AS active_days_count,
	ROUND(SUM(hours_played),2) AS hrs
FROM spotify_ps_dataset
GROUP BY DATENAME(WEEKDAY, CAST(ts AS datetime2))
ORDER BY hrs DESC

-- Peak listening Hour 

SELECT
    -- Formats hour nicely (e.g., "14:00 - 14:59 (2 PM)")
    FORMAT(CAST(ts AS DATETIME2), 'HH:00') AS hour_format,
	COUNT(*) AS total_plays,
	ROUND(SUM(hours_played),2) AS hrs,
	ROUND(SUM(hours_played*60) / COUNT(DISTINCT CAST(ts AS DATE)), 2) AS avg_minutes_per_active_day
FROM spotify_ps_dataset
GROUP BY 
FORMAT(CAST(ts AS DATETIME2), 'HH:00') 
ORDER BY total_plays desc







-- 2. Artist Popularity and Listening Concentration

-- Top 10 Artists by Total Listening Time


SELECT 
	artist_name,
	ROUND(SUM(hours_played),2) AS hrs
FROM spotify_ps_dataset
GROUP BY artist_name
ORDER BY hrs DESC


-- Top 10 Artists by Play Count
SELECT 
	artist_name,
	COUNT(*) AS total_plays,
	ROUND(SUM(hours_played),2) AS hrs
FROM spotify_ps_dataset
GROUP BY artist_name
ORDER BY total_plays DESC


--Percentage of Listening Time Contributed by Top 5 Artists

WITH TOP5Artist AS(
	SELECT TOP 5
		artist_name,
		ROUND(SUM(hours_played),2) AS hrs
	FROM spotify_ps_dataset
	GROUP BY artist_name
	ORDER BY hrs DESC
)
SELECT 
    ROUND(SUM(hrs), 2) AS top_5_total_hours,
    ROUND((SELECT SUM(hours_played) FROM spotify_cleaned_dataset), 2) AS overall_total_hours,
    ROUND(
        (SUM(hrs) * 100.0) / (SELECT SUM(hours_played) FROM spotify_cleaned_dataset), 
        2
    ) AS top_5_percentage_contribution
FROM TOP5Artist



-- 3. Song-Level Analysis

-- Top 10 Songs by Total Listening Time

SELECT 
	track_name,
	artist_name,
	album_name,
	ROUND(SUM(hours_played),2) AS hrs
FROM spotify_ps_dataset
GROUP BY track_name, artist_name, album_name
ORDER BY hrs DESC

-- Most-Played Songs (Top 10 by Play Count)





