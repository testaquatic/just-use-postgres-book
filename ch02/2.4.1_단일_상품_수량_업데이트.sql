-- id가 1일 상품의 수량을 100 증가
UPDATE
    products.catalog
SET stock_quantity = stock_quantity + 100
WHERE id = 1;

-- id가 1이거나 3인 상품의 수량을 50 증가
UPDATE
    products.catalog
SET stock_quantity = stock_quantity + 50
WHERE id = 1
   OR id = 3;

-- 판매 관련 테이블 생성
CREATE TABLE sales.orders
(
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id  INT REFERENCES customers.accounts (id),
    order_date   TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2)
);

CREATE TABLE sales.order_items
(
    order_id   UUID REFERENCES sales.orders (id),
    product_id INT REFERENCES products.catalog (id),
    quantity   INT CHECK (quantity > 0),
    price      DECIMAL(10, 2),
    PRIMARY KEY (order_id, product_id)
);

-- 트랜잭션을 사용해서 거래 정보 저장
BEGIN;
INSERT INTO sales.orders(id, customer_id, total_amount)
VALUES ('a0f85f5b-b6fd-4ea9-8c7f-d05b74a31d91', 1, 26.53);
INSERT INTO sales.order_items(order_id, product_id, quantity, price)
VALUES ('a0f85f5b-b6fd-4ea9-8c7f-d05b74a31d91', 1, 1, 16.54),
       ('a0f85f5b-b6fd-4ea9-8c7f-d05b74a31d91', 4, 1, 9.99);
UPDATE
    products.catalog
SET stock_quantity = stock_quantity - 1
WHERE id IN (1, 4);
COMMIT;

