-- Total Listening hours by Month 

SELECT 
DATENAME(MONTH,CAST(ts AS DATETIME2)) AS listening_month,
ROUND(SUM(hours_played),2) AS hrs
FROM spotify_ps_dataset
GROUP BY DATENAME(MONTH,CAST(ts AS DATETIME2))
ORDER BY hrs 



