-- (a)
/*
    Answer:
          +------------------------+--------+
          | user_id                | name   |
          +------------------------+--------+
          | 8k3aO-mPeyhbR5HUucA5aA | Victor |
          +------------------------+--------+
*/
SELECT user_id,
       name
FROM user
ORDER BY review_count DESC
LIMIT 1;


-- (b)
/*
    Answer:
          +------------------------+--------------+
          | business_id            | name         |
          +------------------------+--------------+
          | 4JNXUYY8wbaaDmk3BPzlWw | Mon Ami Gabi |
          +------------------------+--------------+
*/
SELECT business_id,
       name
FROM business
ORDER BY review_count DESC
LIMIT 1;


-- (c)
/*
    Answer:
          +------------------+
          | avg_review_count |
          +------------------+
          |          24.3193 |
          +------------------+
*/
SELECT avg(review_count) AS avg_review_count
FROM user;


-- (d)
/*
    Answer:
          +-----------------------+
          | avg_rating_diff_count |
          +-----------------------+
          |                    66 |
          +-----------------------+
*/
SELECT count(*) AS avg_rating_diff_count
FROM user
INNER JOIN
  (SELECT user_id,
          avg(stars) AS avg_rating
   FROM review
   GROUP BY user_id) AS temp ON user.user_id = temp.user_id
WHERE abs(temp.avg_rating - user.average_stars) > 0.5;


-- (e)
/* 
    Answer:
          +--------------------------------+
          | more_than_ten_reviews_fraction |
          +--------------------------------+
          |                         0.3311 |
          +--------------------------------+
*/
SELECT count(if(review_count > 10, 1, NULL))/count(*) AS more_than_ten_reviews_fraction
FROM user;


-- (f)
/*
    Answer:
          +-------------------+
          | avg_review_length |
          +-------------------+
          |          698.7808 |
          +-------------------+
*/
SELECT avg(length(text)) AS avg_review_length
FROM review
INNER JOIN
  (SELECT user_id
  FROM user
  WHERE review_count > 10) AS temp on review.user_id = temp.user_id;