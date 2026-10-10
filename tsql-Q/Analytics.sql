
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


SELECT TOP 10 
COUNT(*) AS total_plays,
track_name,
artist_name
FROM spotify_ps_dataset
GROUP BY track_name, artist_name
ORDER BY total_plays DESC


-- Songs with Unusually Low Average Listening Duration


SELECT TOP 20
    track_name,
    artist_name,
    COUNT(*) AS total_plays,
    ROUND(AVG(hours_played*60), 2) AS avg_minutes_played,
    ROUND(AVG(ms_played / 1000.0), 1) AS avg_seconds_played,
    ROUND(SUM(CAST(skipped AS INT)) * 100.0 / COUNT(*), 2) AS skip_rate_pct
FROM spotify_ps_dataset
GROUP BY 
    track_name, 
    artist_name
HAVING 
    COUNT(*) >= 10 
    AND AVG(hours_played*60) < 0.5 -- Average listen time under 30 seconds
ORDER BY 
    avg_minutes_played ASC,
    total_plays DESC;


-- 4. Listening Engagement

-- Overall Skip Rate


SELECT 
    COUNT(*) AS total_plays,
    SUM(CAST(skipped AS INT)) AS total_skips,
    ROUND(SUM(CAST(skipped AS INT)) * 100.0 / COUNT(*), 2) AS overall_skip_rate_pct
FROM 
    spotify_ps_dataset;


--Skip Rate by Hour (Time of Day)

SELECT 
	DATEPART(HOUR, CAST(ts AS datetime2)) AS hours_of_days,
	FORMAT(CAST(ts AS datetime2), 'HH:00') AS hour_format,
	COUNT(*) AS total_plays,
	SUM(CAST(skipped AS INT)) AS total_skips,
	ROUND(SUM(CAST(skipped AS INT)) * 100/ COUNT(*), 2) AS skip_rate_pct
FROM spotify_ps_dataset
GROUP BY DATEPART(HOUR, CAST(ts AS datetime2)),
	FORMAT(CAST(ts AS datetime2), 'HH:00') 
ORDER BY skip_rate_pct DESC;


-- Artists with Highest Skip Rates

SELECT TOP 10
    artist_name,
    COUNT(*) AS total_plays,
    SUM(CAST(skipped AS INT)) AS total_skips,
    ROUND(SUM(CAST(skipped AS INT)) * 100.0 / COUNT(*), 2) AS skip_rate_pct
FROM 
    spotify_ps_dataset
GROUP BY 
    artist_name
HAVING 
    COUNT(*) >= 20
ORDER BY 
    skip_rate_pct DESC,
    total_plays DESC;




-- 5. Weekday vs. Weekend


-- Total Listening Hours

SELECT 
    ROUND(SUM(hours_played), 2) AS total_listening_hours,
    ROUND(SUM(hours_played*60), 2) AS total_listening_minutes,
    COUNT(*) AS total_lifetime_plays
FROM 
    spotify_ps_dataset;

-- Average Listening Time per Day

SELECT 
ROUND(SUM(hours_played)/COUNT(DISTINCT CAST(ts AS DATE)),2) AS avg_hours_per_active_days,
ROUND(SUM(hours_played) / (DATEDIFF(DAY, MIN(CAST(ts AS DATE)), MAX(CAST(ts AS DATE))) + 1.0), 2) AS avg_hours_per_calendar_day
FROM spotify_ps_dataset


-- Number of plays per day

SELECT 
    DATENAME(WEEKDAY, CAST(ts AS DATE)) AS day_of_week,
    COUNT(*) AS plays_on_this_day,
    ROUND(SUM(hours_played), 2) AS total_hours_on_this_day
FROM 
    spotify_ps_dataset
GROUP BY 
    DATENAME(WEEKDAY, CAST(ts AS DATE))
ORDER BY 
    day_of_week DESC


-- 6. Listening Trends and Changes

-- Listening Time by Year


SELECT 
    YEAR(CAST(ts as datetime2)) AS listening_year,
    COUNT(*) AS total_plays,
    ROUND(SUM(hours_played), 2) AS total_hours_played,
    COUNT(DISTINCT CAST(ts AS DATE)) AS active_days,
    ROUND(SUM(hours_played) / COUNT(DISTINCT CAST(ts AS DATE)), 2) AS avg_hours_per_active_day
FROM spotify_ps_dataset
GROUP BY YEAR(CAST(ts AS datetime2))
ORDER BY listening_year ASC


-- Monthly Changes in Listening Activity (Month-over-Month Growth)


WITH MonthlyVolume AS (
    SELECT 
        YEAR(CAST(ts AS DATETIME2)) AS listening_year,
        DATENAME(MONTH, CAST(ts AS DATETIME2)) AS listening_month,
        DATEFROMPARTS(YEAR(CAST(ts AS DATETIME2)), MONTH(CAST(ts AS DATETIME2)), 1) AS month_start_date,
        COUNT(*) AS total_plays,
        ROUND(SUM(hours_played), 2) AS monthly_hours
    FROM 
        spotify_ps_dataset
    GROUP BY 
        YEAR(CAST(ts AS DATETIME2)),
        DATENAME(MONTH, CAST(ts AS DATETIME2)),
        DATEFROMPARTS(YEAR(CAST(ts AS DATETIME2)), MONTH(CAST(ts AS DATETIME2)), 1)
)
SELECT 
    listening_year,
    listening_month,
    monthly_hours,
    total_plays,
    -- Get previous month's hours
    LAG(monthly_hours) OVER (ORDER BY month_start_date ASC) AS prev_month_hours,
    -- Calculate hour difference
    ROUND(monthly_hours - LAG(monthly_hours) OVER (ORDER BY month_start_date ASC), 2) AS mom_hour_change,
    -- Calculate percentage growth/decline
    ROUND(
        ((monthly_hours - LAG(monthly_hours) OVER (ORDER BY month_start_date ASC)) * 100.0) 
        / NULLIF(LAG(monthly_hours) OVER (ORDER BY month_start_date ASC), 0), 
        2
    ) AS mom_growth_pct
FROM 
    MonthlyVolume
ORDER BY 
    month_start_date ASC;



-- Changes in Favorite Artists Over Time (Top Artist per Year)


WITH AnnualArtistRankings AS (
    SELECT 
        YEAR(CAST(ts AS DATETIME2)) AS listening_year,
        artist_name,
        COUNT(*) AS total_plays,
        ROUND(SUM(hours_played), 2) AS total_hours_played,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(CAST(ts AS DATETIME2)) 
            ORDER BY SUM(hours_played) DESC
        ) AS artist_rank
    FROM 
        spotify_ps_dataset
    WHERE 
        artist_name IS NOT NULL
    GROUP BY 
        YEAR(CAST(ts AS DATETIME2)),
        artist_name
)
SELECT 
    listening_year,
    artist_name AS top_artist,
    total_hours_played,
    total_plays
FROM 
    AnnualArtistRankings
WHERE 
    artist_rank = 1
ORDER BY 
    listening_year ASC;