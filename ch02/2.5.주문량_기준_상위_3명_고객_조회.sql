-- 주문량 기준 상위 3명 고객 조회
SELECT c.name,
       c.id,
       COUNT(*) AS total_orders
FROM customers.accounts AS c
         JOIN sales.orders AS s ON c.id = s.customer_id
GROUP BY c.id
ORDER BY total_orders DESC
LIMIT 3;

-- 주문 내역이 없는 고객 조회
SELECT c.name
FROM customers.accounts c
         LEFT JOIN sales.orders s ON c.id = s.customer_id
WHERE s.customer_id IS NULL;

-- 상품 인기도
SELECT c.name,
       c.category,
       c.price,
       SUM(oi.quantity) AS total_sold
FROM products.catalog c
         LEFT JOIN sales.order_items oi ON c.id = oi.product_id
GROUP BY c.id
ORDER BY total_sold DESC NULLS LAST,
         price DESC;

