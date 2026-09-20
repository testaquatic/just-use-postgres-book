-- 상품 가격을 반환하는 함수
CREATE OR REPLACE FUNCTION products.get_product_price(product_id INT)
    RETURNS NUMERIC(10, 2)
AS
$$
SELECT price
FROM products.catalog
WHERE id = product_id;
$$
    LANGUAGE sql;

SELECT products.get_product_price(5);

-- orders 테이블에 status 칼럼 추가
ALTER TABLE sales.orders
    ADD COLUMN status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'ordered'));

UPDATE
    sales.orders
SET status = 'ordered' ALTER TABLE sales.orders
        ADD CONSTRAINT one_pending_order_per_customer
        EXCLUDE USING btree(customer_id WITH =)
WHERE (status = 'pending');

-- 장바구니 함수
CREATE OR REPLACE FUNCTION sales.order_add_item(customer_id_param INT, product_id_param INT, quantity_param INT)
    RETURNS TABLE
            (
                order_id   UUID,
                prod_id    INT,
                quantity   INT,
                prod_price DECIMAL
            )
AS
$$
DECLARE
    pending_order_id UUID;
BEGIN
    SELECT id
    INTO
        pending_order_id
    FROM sales.orders
    WHERE customer_id = customer_id_param
      AND status = 'pending'
    LIMIT 1;
    IF pending_order_id IS NULL THEN
        INSERT INTO sales.orders(customer_id, status)
        VALUES (customer_id_param, 'pending')
        RETURNING
            id
            INTO
                pending_order_id;
    END IF;
    MERGE INTO sales.order_items AS oi
    USING (SELECT id,
                  price
           FROM products.catalog
           WHERE id = product_id_param) AS prod
    ON (oi.order_id = pending_order_id AND oi.product_id = product_id_param)
    WHEN MATCHED THEN
        UPDATE SET quantity = quantity_param
    WHEN NOT MATCHED THEN
        INSERT (order_id, product_id, quantity, price) VALUES (pending_order_id, prod.id, quantity_param, prod.price);
    RETURN QUERY
        SELECT oi.order_id,
               oi.product_id,
               oi.quantity,
               oi.price AS prod_price
        FROM sales.order_items AS oi
        WHERE oi.order_id = pending_order_id;
END;
$$
    LANGUAGE plpgsql;

-- 고객 정보를 가져온다
SELECT id,
       name
FROM customers.accounts
WHERE name = 'Charlie Brown';

-- 상품의 정보를 가져온다.
SELECT id,
       name
FROM products.catalog
WHERE name = 'Morning Glory';

-- 상품을 장바구니에 담는다
SELECT *
FROM
    sales.order_add_item(customer_id_param => 3, product_id_param => 3, quantity_param => 2);

-- 티셔츠의 정보를 가져온다
-- id = 5
SELECT id,
       name
FROM products.catalog
WHERE id = 5;

-- 티셔츠를 장바구니에 담는다
SELECT *
FROM
    sales.order_add_item(customer_id_param => 3, product_id_param => 5, quantity_param => 1);

-- 찰리의 장바구니
SELECT id,
       customer_id,
       status
FROM sales.orders
WHERE customer_id = 3;

-- 주문을 완료하고 장바구니를 비우는 함수
CREATE OR REPLACE FUNCTION sales.order_checkout(customer_id_param INT)
    RETURNS TABLE
            (
                order_id     UUID,
                customer_id  INT,
                total_amount DECIMAL
            )
AS
$$
DECLARE
    pending_order_id   UUID;
    final_total_amount DECIMAL := 0;
BEGIN
    SELECT id
    INTO
        pending_order_id
    FROM sales.orders AS o
    WHERE o.customer_id = customer_id_param
      AND status = 'pending'
    LIMIT 1;
    IF pending_order_id IS NULL THEN
        RAISE EXCEPTION 'No pending order found for customer %', customer_id_param;
    END IF;
    SELECT SUM(oi.quantity * oi.price)
    INTO
        final_total_amount
    FROM sales.order_items oi
    WHERE oi.order_id = pending_order_id;
    UPDATE
        sales.orders
    SET status       = 'ordered',
        total_amount = final_total_amount,
        order_date   = CURRENT_TIMESTAMP
    WHERE id = pending_order_id;
    UPDATE
        products.catalog
    SET stock_quantity = stock_quantity - oi.quantity
    FROM sales.order_items oi
    WHERE products.catalog.id = oi.product_id
      AND oi.order_id = pending_order_id;
    RETURN QUERY
        SELECT o.id,
               o.customer_id,
               o.total_amount
        FROM sales.orders AS o
        WHERE o.id = pending_order_id;
END;
$$
    LANGUAGE plpgsql;

-- 상품을 주문함
SELECT *
FROM
    sales.order_checkout(customer_id_param => 3);

