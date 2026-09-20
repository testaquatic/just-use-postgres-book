-- 밥의 고객 id 가져오기
-- 2
SELECT id,
       name
FROM customers.accounts
WHERE name = 'Bob Smith';

-- 1번 상품을 장바구니에 넣는다.
SELECT *
FROM
    sales.order_add_item(customer_id_param => 2, product_id_param => 1, quantity_param => 1);

-- 주문의 총액을 업데이트 하는 트리거 함수
CREATE OR REPLACE FUNCTION sales.update_order_total()
    RETURNS TRIGGER
AS
$$
BEGIN
    UPDATE
        sales.orders
    SET total_amount =(SELECT COALESCE(SUM(oi.quantity * oi.price), 0)
                       FROM sales.order_items oi
                       WHERE oi.order_id = COALESCE(NEW.order_id, OLD.order_id))
    WHERE id = COALESCE(NEW.order_id, OLD.order_id)
      AND status = 'pending';
    RETURN NEW;
END;
$$
    LANGUAGE plpgsql;

-- 주문 총액 업데이트 트리거 생성
CREATE TRIGGER trigger_update_order_total
    AFTER INSERT OR UPDATE OR DELETE
    ON sales.order_items
    FOR EACH ROW
EXECUTE FUNCTION sales.update_order_total();

-- 2번 고객이 1번 상품 2개를 주문
SELECT *
FROM
    sales.order_add_item(customer_id_param => 2, product_id_param => 1, quantity_param => 2);

-- 2번 고객의 장바구니 확인
SELECT id,
       status,
       total_amount
FROM sales.orders
WHERE id = '79b0beb2-de49-4c44-bb46-a2b6353affcc';

-- 2번 고객이 1번 상품을 추가로 4개 주문
SELECT *
FROM
    sales.order_add_item(customer_id_param => 2, product_id_param => 1, quantity_param => 4);

-- 2번 고객의 장바구니 확인
SELECT id,
       status,
       total_amount
FROM sales.orders
WHERE id = '79b0beb2-de49-4c44-bb46-a2b6353affcc';

-- 2번 고객이 주문 완료
SELECT *
FROM
    sales.order_checkout(2);

