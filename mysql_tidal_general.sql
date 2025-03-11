/* CREATING A WORKING TABLE */

CREATE TABLE tidal.streaming_working AS
  SELECT
    artist_name,
    track_title,
    entry_date,
    stream_duration_ms,
    city_name,
    country_name
  FROM `steadfast-icon-112120.tidal.streaming`
;


/* REVIEWING THE TABLE */

SELECT *
FROM tidal.streaming_working
;


/* EXPLORING THE DATA */

-- Finding the date range of the data

SELECT MIN(entry_date), MAX(entry_date)
FROM tidal.streaming_working
;

-- Artists by Play Count

SELECT artist_name, COUNT(artist_name) AS artist_play_count
FROM tidal.streaming_working
GROUP BY artist_name
ORDER BY artist_play_count DESC
;

-- Songs by Play Count

SELECT track_title, COUNT(track_title) AS song_play_count
FROM tidal.streaming_working
GROUP by track_title
ORDER BY song_play_count DESC
;

-- Top streaming songs from top streaming artist (Imminence)

SELECT track_title, COUNT(track_title) AS play_count
FROM tidal.streaming_working
WHERE artist_name = 'Imminence'
GROUP BY track_title
ORDER BY play_count DESC
;

-- Top 100 Artists by Days & Hrs & Mins

SELECT artist_name,
  FLOOR(SUM(stream_duration_ms)) AS ms,
  (SUM(stream_duration_ms) / (1000 * 60 * 60 * 24)) AS days,
  (SUM(stream_duration_ms) / 3600000) AS hrs,
  (SUM(stream_duration_ms)/1000/60) AS mins
FROM tidal.streaming_working
GROUP BY artist_name
ORDER BY ms DESC Limit 100
;

-- Calculating total streaming stats

SELECT
  SUM(stream_duration_ms) AS total_ms,
  ((SUM(stream_duration_ms) / 1000) / 60) AS total_mins,
  (SUM(stream_duration_ms) / 3600000) AS total_hrs,
  SUM(stream_duration_ms) / 86400000 AS total_days,
  COUNT(DISTINCT track_title) AS total_songs,
  COUNT(DISTINCT artist_name) AS total_artists
FROM tidal.streaming_working
;

-- Streams by Country & City

SELECT DISTINCT country_name, city_name
FROM tidal.streaming_working
ORDER BY country_name ASC, city_name ASC
;

-- Top 10 Songs by Country

WITH cte2 AS(
WITH cte AS (
  SELECT artist_name, track_title, country_name
  FROM tidal.streaming_working
)
SELECT RANK() OVER(PARTITION BY country_name ORDER BY COUNT(track_title) DESC) AS ranking, country_name, artist_name, track_title, COUNT(track_title) AS play_count
FROM cte
GROUP BY country_name, artist_name, track_title
ORDER BY country_name ASC
)
SELECT *
FROM cte2
WHERE ranking <= 10 AND country_name IS NOT NULL
;


/* EXPLORING THE DATA BY TIME */

-- Total Play Duration by Year

WITH cte AS (
  SELECT artist_name, track_title, stream_duration_ms, LEFT(CAST(entry_date AS STRING), 4) AS yr
  FROM tidal.streaming_working
)
SELECT ROUND(SUM(cte.stream_duration_ms)) AS streaming_total_ms, ROUND((SUM(stream_duration_ms) / 3600000)) AS streaming_total_hrs, cte.yr
FROM cte
WHERE cte.yr > '2018' AND cte.yr < '2025'
GROUP BY cte.yr
ORDER BY cte.yr ASC
;

-- Total Play Duration by Month

WITH cte AS (
  SELECT artist_name, track_title, stream_duration_ms, LEFT(CAST(entry_date AS string), 7) AS year_month
  FROM tidal.streaming_working
)
SELECT ROUND(SUM(cte.stream_duration_ms)) AS streaming_total_ms, ROUND((SUM(stream_duration_ms) / 3600000)) AS streaming_total_hrs, cte.year_month
FROM cte
GROUP BY cte.year_month
ORDER BY cte.year_month ASC
;

-- Top 10 Songs by Month

WITH cte2 AS(
WITH cte AS (
  SELECT artist_name, track_title, LEFT(CAST(entry_date AS string), 7) AS year_month
  FROM tidal.streaming_working
)
SELECT RANK() OVER(PARTITION BY year_month ORDER BY COUNT(track_title) DESC) AS ranking, cte.year_month, artist_name, track_title, COUNT(track_title) AS play_count
FROM cte
GROUP BY cte.year_month, artist_name, track_title
ORDER BY cte.year_month ASC
)
SELECT *
FROM cte2
WHERE ranking <= 10
;

-- Play count by day

SELECT LEFT(CAST(entry_date AS string), 10) AS yr_mo_d, COUNT(track_title) AS play_count, 
FROM tidal.streaming_working
GROUP BY yr_mo_d
;

-- Play count by day, ordered

SELECT LEFT(CAST(entry_date AS string), 10) AS yr_mo_d, COUNT(track_title) AS play_count, 
FROM tidal.streaming_working
GROUP BY yr_mo_d
ORDER BY play_count DESC
;


/* EXPLORING THE DATA BY EVENTS */

-- Red 'Sever' by Date

SELECT artist_name, track_title, LEFT(CAST(entry_date AS string), 10) AS play_date
FROM tidal.streaming_working
WHERE track_title = 'Sever'
;

-- Red 'Sever' by Play Count

SELECT LEFT(CAST(entry_date AS STRING), 10) AS play_date, COUNT(track_title) as play_count
FROM tidal.streaming_working
WHERE artist_name = 'RED' AND track_title = 'Sever'
GROUP BY play_date
ORDER BY play_date ASC
;

-- Three Days Grace 'Give Me a Reason' by Play Count

SELECT LEFT(CAST(entry_date AS STRING), 10) AS play_date, COUNT(track_title) as play_count
FROM tidal.streaming_working
WHERE artist_name = 'Three Days Grace' AND track_title = 'Give Me a Reason'
GROUP BY play_date
ORDER BY play_date ASC
;

-- Three Days Grace 'Give Me a Reason' by Play Count

SELECT LEFT(CAST(entry_date AS STRING), 10) AS play_date, COUNT(track_title) as play_count
FROM tidal.streaming_working
WHERE artist_name = 'Imminence' AND track_title = 'To the Light'
GROUP BY play_date
ORDER BY play_date ASC
;

-- Play History on Separation Date and Night (2023-08-10 AND 2023-08-11)

SELECT artist_name, track_title, entry_date, stream_duration_ms
FROM tidal.streaming_working
WHERE entry_date >= '2023-08-10' AND
      entry_date < '2023-08-12'
ORDER BY entry_date ASC
;

-- Play History for Month Following Separation

SELECT artist_name, track_title, entry_date, stream_duration_ms
FROM tidal.streaming_working
WHERE entry_date >= '2023-08-10' AND
      entry_date < '2023-09-10'
ORDER BY entry_date ASC
;

-- Play history on divorce day and day after (2024-03-12 AND 2024-03-13)

SELECT artist_name, track_title, entry_date, stream_duration_ms
FROM tidal.streaming_working
WHERE entry_date >= '2024-03-12' AND
      entry_date < '2024-03-14'
ORDER BY entry_date ASC
;

-- Studying 2023-12-10 (date of abnormal play count)

SELECT LEFT(CAST(entry_date AS string), 10) AS y_mo_d, *
FROM tidal.streaming_working
WHERE LEFT(CAST(entry_date AS string), 10) = '2023-12-10'
;
