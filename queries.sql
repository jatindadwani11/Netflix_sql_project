-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(6),
    type         VARCHAR(10),
    title        VARCHAR(150),
    director     VARCHAR(210),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(15),
    listed_in    VARCHAR(100),
    description  VARCHAR(250)
);
SELECT * FROM netflix;

-- 1. Count the Number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*) as total_content
FROM netflix
GROUP BY 1;

-- 2. Find the Most Common Rating for Movies and TV Shows

SELECT
	type,
	rating
FROM
(SELECT 
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1,2) AS t1
WHERE 
	ranking = 1

-- 3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT * 
FROM netflix
WHERE 
	release_year = 2020
	AND
	type = 'Movie';

-- 4. Find the Top 5 Countries with the Most Content on Netflix

SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the Longest Movie

SELECT * 
FROM netflix
WHERE 
	type = 'Movie'
	AND
	SPLIT_PART(duration,' ',1)::numeric = (SELECT MAX(SPLIT_PART(duration,' ',1)::numeric) FROM netflix);

-- 6. Find Content Added in the Last 5 Years

SELECT *
FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT * 
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List All TV Shows with More Than 5 Seasons

SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration,' ',1)::numeric > 5;

-- 9. Count the Number of Content Items in Each Genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
	COUNT(*)
FROM netflix
GROUP BY 1;

/* 
10.Find each year and the average content release in India on netflix,
return top 5 year with highest avg content release!
*/

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as date,
	COUNT(*),
	ROUND(COUNT(*):: numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100 , 2) as avg_content
	FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 1 ASC;

-- 11. List All Movies that are Documentaries

SELECT * 
FROM netflix
WHERE
	type = 'Movie'
	AND
	listed_in Ilike '%documentaries%';

-- 12. Find All Content Without a Director

SELECT *
FROM netflix
WHERE
	director is null;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT 
	COUNT(*)
FROM netflix
WHERE
	casts ILIKE '%salman khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
	UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
	COUNT(*) AS content_appeared_in
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*
15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. 
Count the number of items in each category.
*/

WITH new_table AS (
SELECT *,
	CASE
	WHEN 
		description ILIKE '%kill%' OR
		description ILIKE '%violence%' THEN 'Bad Content'
		ELSE 'Good Content'
	END AS category
FROM netflix
)
SELECT 
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1;
	

-- 16. Percentage Distribution of content

SELECT 
    type,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM netflix
GROUP BY type;

