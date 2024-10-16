-----------------------------------------------------------------------------------------------------------------------------------  
-----------------------------------------HOST PERFORMANCE AND REVIEW ANALYTICS-----------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

-- 	1) How can we calculate the average response time for each host and 
-- identify those with response times significantly higher than the average?
	select * from(
	 with host_response_data as(select distinct host_id as host_id,cast(NULLIF(host_response_rate ,'N/A')as float)as response_rate from listings_detailed),
	 
	 avg_responserate_byeach_host as (select distinct host_id as id, 
	  AVG(cast(NULLIF(host_response_rate ,'N/A')as float))as avg_time_byhost from listings_detailed group by id )
	  
	  
  select host_id,ar.avg_time_byhost,(select AVG(cast(NULLIF(host_response_rate ,'N/A')as float))as avg_time from listings_detailed ),
	  
  case when response_rate>(select AVG(cast(NULLIF(host_response_rate ,'N/A')as float))as avg_time from listings_detailed )
	   then 'higher '
  when response_rate<(select AVG(cast(NULLIF(host_response_rate ,'N/A')as float))as avg_time from listings_detailed )
	   then 'lower'
	   when response_rate is null then 'not_available'
  else 'stable'
  end as response_time from host_response_data hr join  avg_responserate_byeach_host ar on hr.host_id=ar.id
  order by 
  host_id ) where response_time not in ('not_available','lower','stable')

  
  
-- 2)  Host Review Score Trends
-- Question: How can we analyze the trend of review scores for each host over time?

with over_time as(
select listing_id,extract(month from date )as month,extract(year from date)as year from reviews)
,trends as(
SELECT 
        id as l_id, host_id as id,
        (COALESCE(review_scores_rating, 0) +
         COALESCE(review_scores_accuracy, 0) +
         COALESCE(review_scores_cleanliness, 0) +
         COALESCE(review_scores_checkin, 0) +
         COALESCE(review_scores_communication, 0) +
         COALESCE(review_scores_location, 0) +
         COALESCE(review_scores_value, 0)) / 7.0  as review_score
    FROM 
        listings_detailed  )
		
		select t.id,count(t.review_score),ot.month,ot.year from over_time ot join trends t on ot.listing_id =t.l_id
		group by t.id,ot.month,ot.year order by 1 ,3,4
 

-- checking the answer

select count((COALESCE(review_scores_rating, 0) +
         COALESCE(review_scores_accuracy, 0) +
         COALESCE(review_scores_cleanliness, 0) +
         COALESCE(review_scores_checkin, 0) +
         COALESCE(review_scores_communication, 0) +
         COALESCE(review_scores_location, 0) +
         COALESCE(review_scores_value, 0)) / 7.0) from reviews r join listings_detailed l on r.listing_id =l.id 
		 
where extract(year from date) ='2011' and extract(month from date)	='3' and l.host_id='13660'
		 
		 
select * from calendar

-- 3)Superhost Performance Comparison
-- Question: How can we compare the performance of superhosts with non-superhosts in terms of review scores and response times?
with cnt as (select * from(
	 with host_response_data as(select distinct host_id as host_id,host_is_superhost,cast(NULLIF(host_response_rate ,'N/A')as float)as response_rate 
								from listings_detailed),
	 
	 avg_responserate_byeach_host as (select distinct host_id as id, 
	  AVG(cast(NULLIF(host_response_rate ,'N/A')as float))as avg_time_byhost from listings_detailed group by id ),
	
	review_score as(SELECT host_id,
        
        (COALESCE(review_scores_rating, 0) +
         COALESCE(review_scores_accuracy, 0) +
         COALESCE(review_scores_cleanliness, 0) +
         COALESCE(review_scores_checkin, 0) +
         COALESCE(review_scores_communication, 0) +
         COALESCE(review_scores_location, 0) +
         COALESCE(review_scores_value, 0)) / 7.0 as review_score
    FROM 
        listings_detailed
	
	)
	
select hr.host_id,host_is_superhost,review_score,
  case when response_rate>(select AVG(cast(NULLIF(host_response_rate ,'N/A')as float))as avg_time from listings_detailed )
	   then 'higher '
  when response_rate<(select AVG(cast(NULLIF(host_response_rate ,'N/A')as float))as avg_time from listings_detailed )
	   then 'lower'
	   when response_rate is null then 'not_available'
  else 'stable'
  end as response_time from host_response_data hr join  avg_responserate_byeach_host ar on hr.host_id=ar.id join 
	review_score r on ar.id=r.host_id
  order by 
  host_id ) where host_is_superhost is not null )
 select host_is_superhost,ROUND(avg(review_score),2) AS avg_review_score,response_time,count(*) from cnt group by 1 ,3
  
   select distinct(response_time)from cnt
  
  
  select * from listingS_detailed where host_is_superhost is null
  
  

select host_id,host_is_superhost,response_time,review_score from listings_detailed 



-- 4) Host Review Sentiment Analysis
-- Question: How can we perform sentiment analysis on review comments to categorize them as positive, negative, or neutral, 
-- and analyze the impact on host performance?



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
               OR comments ILIKE '%Recommend%' 
               THEN 'positive_review_keyword'
               WHEN comments ILIKE '%Bad%' 
               OR comments ILIKE '%Poor%'
               OR comments ILIKE '%Dirty%'
               OR comments ILIKE '%Noisy%'
               OR comments ILIKE '%Uncomfortable%'
               OR comments ILIKE '%Rude%'
               OR comments ILIKE '%Misleading%'
               OR comments ILIKE '%Slow%'
               OR comments ILIKE '%Broken%'
               OR comments ILIKE '%Smell%' 
               THEN 'negative_review_keyword'
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