....ASSIGNMENT..........

#.Assuming you are a junior data analyst of WinkIT, and your responsibility is to provide accurate data  insights for the cross functional teams. 
You receive a request from the management in order to support their data-driven decisions, 
your task is to provide report considering the following  business problems/questions. 
Using the datasets with users, bookings and payments tables provided in google bigquery to  answer the questions. 
Task 1: To understand the performance by countries, please find the top 10 countries with the  highest number of executed bookings. 
Task 2: Our revenue is generated from services booked by users. However, some users prefer to  use direct services without booking. 
The finance team would like to know the total payments  made by each user who has made payments but hasn't booked any services. 
It would be nice to  include the locations of these users. 
Task 3: The marketing squad is planning a campaign targeting users who have made at least one  or multiple payments. 
As a data analyst, you are asked to retrieve the data according to the  marketing team's requirements. 
They also want to know the total payments accruing from each;

# APPROACH OR PROPOSED SOLUTION..........................

SELECT * FROM supermarket_data.bookings_data B;
SELECT * FROM supermarket_data.payments_data P;
SELECT * FROM supermarket_data.users_data U;

                   #QUESTION 1...;
# we need the following for this question: countries, bookings(exeecuted), id(or status)

SELECT country_code as Country, 
count(B.id) AS num_executed_bookings 
FROM supermarket_data.bookings_data B
LEFT JOIN supermarket_data.users_data U
ON B.user_id = U.user_id
WHERE STATUS = 'executed'
GROUP BY country_code
ORDER BY num_executed_bookings DESC
LIMIT 10;

# If we use status, we will have same results.

SELECT country_code as Country, 
count(status) AS num_executed_bookings 
FROM supermarket_data.bookings_data B
LEFT JOIN supermarket_data.users_data U
ON B.user_id = U.user_id
WHERE STATUS = 'executed'
GROUP BY country_code
ORDER BY num_executed_bookings DESC
LIMIT 10;

# If we are interested we can also use the IS NOT statement

SELECT country_code as Country, 
count(B.id) AS num_executed_bookings 
FROM supermarket_data.bookings_data B
LEFT JOIN supermarket_data.users_data U
ON B.user_id = U.user_id
WHERE STATUS != 'Scheduled' OR status != 'Cancelled'
GROUP BY country_code
ORDER BY num_executed_bookings DESC
LIMIT 10;

# We can also use the CTE method to approach this question as follows

WITH COUNTSTATUS AS (
SELECT
country_code,
COUNT(B.id) As num_of_exe_bookings,
SUM(CASE WHEN STATUS = 'Executed' THEN 1 ELSE 0 END) As num_executed,
SUM(CASE WHEN STATUS = 'Scheduled' THEN 1 ELSE 0 END) As num_sch,
SUM(CASE WHEN STATUS = 'Cancelled' THEN 1 ELSE 0 END) As num_can
FROM supermarket_data.bookings_data B
LEFT JOIN supermarket_data.users_data U
ON B.user_id = U.user_id
GROUP BY country_code
)
SELECT country_code,
SUM(num_executed) As exe_bk,
SUM(num_sch) As sch,
SUM(num_can) As can
FROM COUNTSTATUS
GROUP BY country_code
ORDER BY 2, 3, 4 DESC
LIMIT 10;


                   #QUESTION 2...;

SELECT B.user_id, U.country_code as Country, 
SUM(P.payment_amount) AS Total_payment_amount
FROM supermarket_data.users_data U
LEFT JOIN supermarket_data.bookings_data B
ON U.user_id = B.user_id
INNER JOIN supermarket_data.payments_data P
ON U.user_id = P.user_id
WHERE B.user_id is NULL
GROUP BY B.user_id, U.country_code;

#.............. QUESTION 3................

SELECT * FROM supermarket_data.bookings_data B;
SELECT * FROM supermarket_data.payments_data P;
SELECT * FROM supermarket_data.users_data U;

SELECT
U.user_id,
COUNT(P.id) As payment_count,
ROUND(SUM(P.payment_amount), 2) As Total_payment_amount
FROM supermarket_data.users_data U
LEFT JOIN supermarket_data.payments_data P
ON U.user_id = P.user_id
GROUP BY U.user_id, U.country_code
HAVING payment_count >= 1;
