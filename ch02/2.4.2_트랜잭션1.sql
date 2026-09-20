-- 1
-- 트랜잭션을 시작하고 id가 1인 상품 재고 수량 확인
-- 149
BEGIN;
SELECT stock_quantity
FROM products.catalog
WHERE id = 1;

-- 2 
-- 상품 수량을 업데이트
-- 148
UPDATE products.catalog
SET stock_quantity = stock_quantity - 1
WHERE id = 1;

-- 5
-- 커밋
COMMIT;