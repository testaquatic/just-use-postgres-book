-- 상품 가격에 제약조건 설정
ALTER TABLE products.catalog
    ADD CONSTRAINT catalog_price_check CHECK (price > 0);

-- 잘못된 상품 가격 입력
UPDATE
    products.catalog
SET price = -16
WHERE name = 'Morning Glory';

-- 리뷰에 제약조건 설정
ALTER TABLE products.reviews
    ALTER COLUMN review SET NOT NULL,
    ADD CONSTRAINT review_rank_check CHECK (rank >= 1 AND rank <= 5);

-- product_id에 제약조건 설정
ALTER TABLE products.reviews
    ADD CONSTRAINT products_reviews_products_fk FOREIGN KEY (product_id) REFERENCES products.catalog (id);

-- accounts 테이블 생성
CREATE TABLE customers.accounts
(
    id            SERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    email         TEXT NOT NULL,
    password_hash TEXT NOT NULL
);

-- customer_id에 외래 키 생성
ALTER TABLE products.reviews
    ADD CONSTRAINT products_review_customer_id_fk FOREIGN KEY (customer_id) REFERENCES customers.accounts (id);

-- 새로운 고객 추가하기
INSERT INTO customers.accounts(name, email, password_hash)
VALUES ('Alice Johnson', 'alice.johnson@example.com', 'hashed_password_1'),
       ('Bob Smith', 'bob.smith@example.com', 'hashed_password_2'),
       ('Charlie Brown', 'charlie.brown@example.com', 'hashed_password_3');

-- 고객 목록 조회
SELECT id,
       name
FROM customers.accounts;

-- 고객이 상품 정보 조회
SELECT id,
       name
FROM products.catalog
WHERE name = 'Sunrise Brew Co. Mug';

-- 잘못된 product_id 사용
INSERT INTO products.reviews(product_id, customer_id, review, rank)
VALUES (1004, 1, 'This mug is perfect - sturdy, stylish and keeps my coffee warm for a good while.', 5);

-- 수정한 리뷰
INSERT INTO products.reviews(product_id, customer_id, review, rank)
VALUES (4, 1, 'This mug is perfect - sturdy, stylish and keeps my coffee warm for a good while.', 5);

-- 부모 테이블 삭제 시도
DELETE
FROM customers.accounts
WHERE id = 1;

-- 소프트 삭제 방식 도입
ALTER TABLE customers.accounts
    ADD COLUMN deleted BOOLEAN DEFAULT FALSE;

-- 고객 삭제
UPDATE
    customers.accounts
SET deleted = TRUE
WHERE id = 1;

