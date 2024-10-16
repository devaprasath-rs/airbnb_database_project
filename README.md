# Madrid_airbnb Host review and performance analysis SQL Project

## Project Overview

**Project Title**: Host review and Performance Analysis  
**Level**: Intermediate 
**Database**: `madrid_airbnb_db`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

**1. Average Response Time Calculation**
- Calculate average response times for hosts using data from listings.
- Identify hosts with response times above the average to suggest improvements.

**2. Host Review Score Trends**
- Analyze monthly trends in review scores for each host over time.
- Provide insights on how review score fluctuations affect host reputation.

**3. Superhost Performance Comparison**
- Compare average review scores of superhosts versus non-superhosts.
- Evaluate the effect of superhost status on response times and service quality.

**4. Host Review Sentiment Analysis**
- Classify reviews as positive, negative, or neutral based on keywords.
- Analyze how sentiment influences overall host performance metrics.


## Project Structure

## 1. Database Setup

- **Database Creation**: The project starts by creating a database named `airbnb_data_db`.
- **Table Creation**: The following tables are created to store relevant data:
  
  - **Table `listings_detailed`**: This table stores detailed information about each listing, including columns for:
    - `id`: Unique identifier for each listing.
    - `listing_url`: URL of the listing.
    - `scrape_id`: Identifier for the scraping instance.
    - `last_scraped`: Date of the last scrape.
    - `name`: Name of the listing.
    - `description`: Description of the listing.
    - `neighborhood_overview`: Overview of the neighborhood.
    - Additional columns for host information, location, property details, and review scores.

  - **Table `neighbourhood`**: This table captures neighborhood data with columns for:
    - `neighbourhood_group`: Grouping of neighborhoods.
    - `neighbourhood`: Specific neighborhood names.

  - **Table `reviews`**: This table logs reviews with columns for:
    - `listing_id`: Reference to the associated listing.
    - `date`: Date of the review.

  - **Table `reviews_detailed`**: This table stores detailed review information, including:
    - `listing_id`: Reference to the associated listing.
    - `id`: Unique identifier for each review.
    - `date`: Date of the review.
    - `reviewer_id`: Unique identifier for the reviewer.
    - `reviewer_name`: Name of the reviewer.
    - `comments`: Text of the review comments.


### 2. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **How can we calculate the average response time for each host and identify those with response times significantly higher than the average? **:

```sql
SELECT * FROM (
    WITH host_response_data AS (
        SELECT DISTINCT host_id AS host_id, 
        CAST(NULLIF(host_response_rate, 'N/A') AS FLOAT) AS response_rate 
        FROM listings_detailed
    ),
    avg_responserate_byeach_host AS (
        SELECT DISTINCT host_id AS id, 
        AVG(CAST(NULLIF(host_response_rate, 'N/A') AS FLOAT)) AS avg_time_byhost 
        FROM listings_detailed 
        GROUP BY id
    )
    SELECT 
        host_id, 
        ar.avg_time_byhost,
        (SELECT AVG(CAST(NULLIF(host_response_rate, 'N/A') AS FLOAT)) AS avg_time FROM listings_detailed) AS avg_time,
        CASE 
            WHEN response_rate > (SELECT AVG(CAST(NULLIF(host_response_rate, 'N/A') AS FLOAT)) AS avg_time FROM listings_detailed) THEN 'higher' 
            WHEN response_rate < (SELECT AVG(CAST(NULLIF(host_response_rate, 'N/A') AS FLOAT)) AS avg_time FROM listings_detailed) THEN 'lower' 
            WHEN response_rate IS NULL THEN 'not_available' 
            ELSE 'stable' 
        END AS response_time 
    FROM host_response_data hr 
    JOIN avg_responserate_byeach_host ar ON hr.host_id = ar.id 
    ORDER BY host_id
) WHERE response_time NOT IN ('not_available', 'lower', 'stable');

```

2. **How can we analyze the trend of review scores for each host over time?**:
```sql
WITH over_time AS (
    SELECT listing_id, EXTRACT(month FROM date) AS month, EXTRACT(year FROM date) AS year 
    FROM reviews
), trends AS (
    SELECT 
        id AS l_id, 
        host_id AS id,
        (COALESCE(review_scores_rating, 0) +
        COALESCE(review_scores_accuracy, 0) +
        COALESCE(review_scores_cleanliness, 0) +
        COALESCE(review_scores_checkin, 0) +
        COALESCE(review_scores_communication, 0) +
        COALESCE(review_scores_location, 0) +
        COALESCE(review_scores_value, 0)) / 7.0 AS review_score
    FROM listings_detailed
)
SELECT t.id, COUNT(t.review_score), ot.month, ot.year 
FROM over_time ot 
JOIN trends t ON ot.listing_id = t.l_id 
GROUP BY t.id, ot.month, ot.year 
ORDER BY 1, 3, 4;

```

3. **How can we compare the performance of superhosts with non-superhosts in terms of review scores and response times?.**:
```sql
WITH cnt AS (
    SELECT * FROM (
        WITH host_response_data AS (
            SELECT DISTINCT host_id AS host_id, 
            host_is_superhost, 
            CAST(NULLIF(host_response_rate, 'N/A') AS FLOAT) AS response_rate 
            FROM listings_detailed
        ),
        avg_responserate_byeach_host AS (
            SELECT DISTINCT host_id AS id, 
            AVG(CAST(NULLIF(host_response_rate, 'N/A') AS FLOAT)) AS avg_time_byhost 
            FROM listings_detailed 
            GROUP BY id
        ),
        review_score AS (
            SELECT host_id,
            (COALESCE(review_scores_rating, 0) +
            COALESCE(review_scores_accuracy, 0) +
            COALESCE(review_scores_cleanliness, 0) +
            COALESCE(review_scores_checkin, 0) +
            COALESCE(review_scores_communication, 0) +
            COALESCE(review_scores_location, 0) +
            COALESCE(review_scores_value, 0)) / 7.0 AS review_score
            FROM listings_detailed
        )
        SELECT 
            hr.host_id, 
            host_is_superhost, 
            review_score,
            CASE 
                WHEN response_rate > (SELECT AVG(CAST(NULLIF(host_response_rate, 'N/A') AS FLOAT)) AS avg_time FROM listings_detailed) THEN 'higher' 
                WHEN response_rate < (SELECT AVG(CAST(NULLIF(host_response_rate, 'N/A') AS FLOAT)) AS avg_time FROM listings_detailed) THEN 'lower' 
                WHEN response_rate IS NULL THEN 'not_available' 
                ELSE 'stable' 
            END AS response_time 
        FROM host_response_data hr 
        JOIN avg_responserate_byeach_host ar ON hr.host_id = ar.id 
        JOIN review_score r ON ar.id = r.host_id 
        ORDER BY host_id
    ) WHERE host_is_superhost IS NOT NULL
)
SELECT 
    host_is_superhost, 
    ROUND(AVG(review_score), 2) AS avg_review_score, 
    response_time, 
    COUNT(*) 
FROM cnt 
GROUP BY 1, 3;

SELECT DISTINCT(response_time) FROM cnt;

SELECT * FROM listings_detailed WHERE host_is_superhost IS NULL;

SELECT host_id, host_is_superhost, response_time, review_score FROM listings_detailed;
_sales
GROUP BY 1
```

4. **How can we perform sentiment analysis on review comments to categorize them as positive, negative, or neutral, and analyze the impact on host performance?**:
```sql
WITH review_type AS (
    SELECT listing_id,
           CASE 
               WHEN comments ILIKE '%Good%' 
               OR comments ILIKE '%Great%'
               OR comments ILIKE '%Excellent%'
               OR comments ILIKE '%Amazing%'
               OR comments ILIKE '%Fantastic%'
               OR comments ILIKE '%Clean%'
               OR comments ILIKE '%Comfortable%'
               OR comments ILIKE '%Welcoming%'
               OR comments ILIKE '%Responsive%'
               OR comments ILIKE '%Recommend%' THEN 'positive_review_keyword'
               WHEN comments ILIKE '%Bad%' 
               OR comments ILIKE '%Poor%'
               OR comments ILIKE '%Dirty%'
               OR comments ILIKE '%Noisy%'
               OR comments ILIKE '%Uncomfortable%'
               OR comments ILIKE '%Rude%'
               OR comments ILIKE '%Misleading%'
               OR comments ILIKE '%Slow%'
               OR comments ILIKE '%Broken%'
               OR comments ILIKE '%Smell%' THEN 'negative_review_keyword'
               ELSE 'neutral'
           END AS review_classification
    FROM reviews_detailed
),
host_performance AS (
    SELECT id AS listing_id, host_id 
    FROM listings_detailed 
),
classification_count AS (
    SELECT hp.host_id,
           rt.review_classification,
           COUNT(rt.review_classification) AS cnt 
    FROM host_performance hp 
    JOIN review_type rt ON hp.listing_id = rt.listing_id 
    GROUP BY hp.host_id, rt.review_classification
),
review_score AS (
    SELECT l.host_id, 
           (COALESCE(review_scores_rating, 0) +
            COALESCE(review_scores_accuracy, 0) +
            COALESCE(review_scores_cleanliness, 0) +
            COALESCE(review_scores_checkin, 0) +
            COALESCE(review_scores_communication, 0) +
            COALESCE(review_scores_location, 0) +
            COALESCE(review_scores_value, 0)) / 7.0 AS review_score
    FROM listings_detailed l
)

SELECT 
    cc.host_id,
    MAX(rs.review_score) AS review_score,  -- Use MAX() as there might be multiple listings per host
    SUM(CASE WHEN cc.review_classification = 'positive_review_keyword' THEN cc.cnt ELSE 0 END) AS positive_cnt,
    SUM(CASE WHEN cc.review_classification = 'negative_review_keyword' THEN cc.cnt ELSE 0 END) AS negative_cnt,
    SUM(CASE WHEN cc.review_classification = 'neutral' THEN cc.cnt ELSE 0 END) AS neutral_cnt
FROM 
    classification_count cc
JOIN 
    review_score rs ON cc.host_id = rs.host_id
GROUP BY 
    cc.host_id;

```


## Findings

**1. Average Response Time for Each Host**
- Hosts with significantly higher average response times may struggle with guest satisfaction, indicating a potential area for improvement in their responsiveness.
- The analysis can identify hosts with lower response times compared to the overall average, highlighting those who may be providing better customer service.

---

**2. Host Review Score Trends**
- Review scores can fluctuate over time, indicating periods of high and low guest satisfaction for each host.
- Identifying trends in review scores allows hosts to recognize the impact of changes in their service or property features, helping them make informed decisions for improvement.

---

**3. Superhost Performance Comparison**
- Superhosts generally tend to have higher average review scores compared to non-superhosts, indicating that their experience and commitment to quality are reflected in guest reviews.
- The performance comparison reveals differences in response times, suggesting that superhosts are more responsive, which contributes to better guest experiences and higher ratings.

---

**4. Host Review Sentiment Analysis**
- Positive reviews are linked to higher overall review scores, demonstrating the importance of guest feedback in evaluating host performance.
- The sentiment analysis can help hosts identify common themes in reviews, enabling them to reinforce positive aspects of their service while addressing negative feedback for continuous improvement.

--- 

These findings can be utilized to improve host performance, enhance guest satisfaction, and guide future strategies for property management. 



## Conclusion
This project provides insights into host performance and guest satisfaction on the Airbnb platform by analyzing average response times, review score trends, superhost performance, and sentiment from guest comments. The findings indicate that quicker response times correlate with higher ratings, while tracking review scores helps hosts understand guest perceptions. The comparison between superhosts and non-superhosts highlights the advantages of superhost status in terms of feedback and responsiveness. Overall, these insights can guide hosts in enhancing their performance and guest experiences, ultimately strengthening their competitive position in the rental market.


Thank you for your support, and I look forward to connecting with you!
