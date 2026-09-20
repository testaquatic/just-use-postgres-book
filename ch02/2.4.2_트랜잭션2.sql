-- 3
-- 트랜잭션을 시작하고 id가 1인 상품의 재고 수량을 확인
-- 149 => 트랜잭션1을 커밋하지 않음
BEGIN;
SELECT stock_quantity
FROM products.catalog
WHERE id = 1;
-- 4 상품 수량을 업데이트
-- 작업 차단
UPDATE
    products.catalog
SET stock_quantity = stock_quantity - 1
WHERE id = 1;
-- 6
-- 작업 차단 해제 후 커밋
COMMIT;

-- 197
SELECT name,
       stock_quantity
FROM products.catalog
WHERE id = 1;

