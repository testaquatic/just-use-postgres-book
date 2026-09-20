-- 판매 현황

SELECT c.name                      AS procduct_name,
       c.category,
       SUM(oi.quantity)            AS total_quantity_sold,
       SUM(oi.quantity * oi.price) AS total_revenue
FROM products.catalog c
         LEFT JOIN sales.order_items oi ON c.id = oi.product_id
GROUP BY c.id
ORDER BY total_quantity_sold DESC,
         total_revenue DESC;

-- 뷰 생성

CREATE VIEW sales.product_sales_summary AS
SELECT c.name                      AS procduct_name,
       c.category,
       SUM(oi.quantity)            AS total_quantity_sold,
       SUM(oi.quantity * oi.price) AS total_revenue
FROM products.catalog c
         LEFT JOIN sales.order_items oi ON c.id = oi.product_id
GROUP BY c.id
ORDER BY total_quantity_sold DESC,
         total_revenue DESC;

-- 뷰 조회

SELECT *
FROM sales.product_sales_summary;

-- 뷰 조회 - 조건 지정

SELECT *
FROM sales.product_sales_summary
WHERE category = 'coffee';

-- 구체화된 뷰

CREATE MATERIALIZED VIEW sales.monthly_sales_summary AS
SELECT date_trunc('month', o.order_date) AS sales_month,
       SUM(oi.quantity * oi.price)       AS total_revenue,
       COUNT(DISTINCT (o.id))            AS total_orders
FROM sales.orders o
         JOIN sales.order_items oi ON o.id = oi.order_id
GROUP BY sales_month
ORDER BY sales_month;


SELECT *
FROM sales.monthly_sales_summary;

-- 커피 추가 구입
SELECT sales.order_add_item(
               customer_id_param => 3,
               product_id_param => 1,
               quantity_param => 3
       );

-- 커피 추가 구입
SELECT sales.order_add_item(
               customer_id_param => 3,
               product_id_param => 3,
               quantity_param => 2
       );

-- 주문 완료
SELECT *
FROM sales.order_checkout(customer_id_param => 3);

-- 구체화된 뷰 확인
SELECT *
FROM sales.monthly_sales_summary;

-- 구체화된 뷰 갱신
REFRESH MATERIALIZED VIEW sales.monthly_sales_summary;

-- 재확인
SELECT *
FROM sales.monthly_sales_summary;