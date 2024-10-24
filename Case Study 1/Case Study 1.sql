CREATE DATABASE SQLWeeklyChallenge1;
USE SQLWeeklyChallenge1;


CREATE TABLE sales (
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  

 --   Case Study Questions


-- 1. What is the total amount each customer spent at the restaurant?
SELECT S.customer_id AS customer, SUM(M.price) AS amount_spent
     FROM
         sales AS S
         INNER JOIN
         menu AS M
     ON S.product_id = M.product_id
     GROUP BY S.customer_id
     ORDER BY S.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id AS customer, COUNT(DISTINCT order_date) AS visited_days
     FROM sales
     GROUP BY customer_id
     ORDER BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT DISTINCT A.customer_id AS customer, M.product_name AS item_name
     FROM
         (
             SELECT R.customer_id, R.product_id
             FROM
                 (
                     SELECT *,
                            RANK() over (PARTITION BY customer_id ORDER BY order_date) AS rnk
                     FROM sales
                 ) AS R
             WHERE R.rnk = 1
         ) AS A
         INNER JOIN
         menu AS M
     ON A.product_id = M.product_id
     ORDER BY A.customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT R.product_id, M.product_name AS product, R.sold_count AS purchase_count
     FROM
         (
             SELECT product_id, COUNT(product_id) AS sold_count
             FROM sales
             GROUP BY product_id
             ORDER BY sold_count DESC
             LIMIT 1
         ) AS R
         INNER JOIN
         menu AS M
     ON R.product_id = M.product_id;

-- 5. Which item was the most popular for each customer?
SELECT R.customer_id, M.product_name, R.bought
     FROM
         (
             SELECT B.customer_id, B.product_id, B.bought
             FROM
                 (
                     SELECT *,
                            RANK() over (PARTITION BY A.customer_id ORDER BY A.bought DESC) AS most_bought
                     FROM
                         (
                             SELECT customer_id, product_id, COUNT(product_id) AS bought
                             FROM sales
                             GROUP BY customer_id, product_id
                         ) AS A
                 ) AS B
             WHERE B.most_bought = 1
         ) AS R
         INNER JOIN
         menu AS M
     ON R.product_id = M.product_id
     ORDER BY R.customer_id;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT A.customer_id, M.product_name
     FROM
         (
             SELECT R.product_id, R.customer_id
             FROM
                 (
                     SELECT S.customer_id, S.product_id, S.order_date,
                            RANK() over (PARTITION BY S.customer_id ORDER BY S.order_date) AS rnk
                     FROM sales AS S LEFT JOIN members AS M
                     ON S.customer_id = M.customer_id
                     WHERE S.order_date >= M.join_date
                 ) AS R
             WHERE R.rnk = 1
         ) AS A
         INNER JOIN
         menu AS M
     ON A.product_id = M.product_id
     ORDER BY A.customer_id;

-- 7. Which item was purchased just before the customer became a member?
SELECT R.customer_id, M.product_name
     FROM
         (
             SELECT A.customer_id, A.order_date, A.product_id, A.rnk
             FROM
                 (
                     SELECT S.customer_id, S.order_date, S.product_id,
                            RANK() over (PARTITION BY S.customer_id ORDER BY S.order_date DESC) AS rnk
                     FROM sales AS S INNER JOIN members AS M
                     ON S.customer_id = M.customer_id
                     WHERE S.order_date < M.join_date
                 ) AS A
             WHERE A.rnk = 1
         ) AS R
         INNER JOIN
         menu AS M
     ON R.product_id = M.product_id
     ORDER BY R.customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT R.customer_id AS customer, COUNT(R.product_id) AS item_count, SUM(M.price) AS amount_spent
     FROM
         (
             SELECT S.customer_id, S.product_id
             FROM sales AS S INNER JOIN members AS M
             ON S.customer_id = M.customer_id
             WHERE S.order_date < M.join_date
         ) AS R
         INNER JOIN
         menu AS M
     ON R.product_id = M.product_id
     GROUP BY R.customer_id
     ORDER BY customer;
     


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH total_points_customers AS (
         SELECT
             S.customer_id, IF(M.product_name = 'sushi', M.price * 20, M.price * 10) AS points_earned
         FROM sales AS S INNER JOIN menu AS M
         ON S.product_id = M.product_id
     )
     SELECT customer_id, SUM(points_earned) AS total_points
     FROM total_points_customers
     GROUP BY customer_id
     ORDER BY customer_id;
     

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi -
--     how many points do customer A and B have at the end of January?
WITH
         subscribers AS (
             SELECT S.customer_id, S.order_date, S.product_id, M.join_date
             FROM sales AS S INNER JOIN members AS M
             ON S.customer_id = M.customer_id
         ),
         subscriber_points AS (
             SELECT
                 S.customer_id,
                 CASE
                     WHEN S.order_date >= S.join_date AND S.order_date <= (S.join_date + 6) THEN M.price * 20
                     WHEN M.product_name = 'sushi' THEN M.price * 20
                     ELSE M.price * 10
                 END AS points
             FROM subscribers AS S INNER JOIN menu AS M
             ON S.product_id = M.product_id
             WHERE S.order_date < '2021-02-01'
         )
     SELECT customer_id, SUM(points) AS points_offers
     FROM subscriber_points
     GROUP BY customer_id
     ORDER BY customer_id;

