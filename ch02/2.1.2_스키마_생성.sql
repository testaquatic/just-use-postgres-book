-- 스키마를 생성한다.
CREATE SCHEMA products;

CREATE SCHEMA customers;

CREATE SCHEMA sales;

-- 현재 스키마를 변경한다.
SET search_path TO products;

-- 제품 카탈로그 테이블을 생성한다.
CREATE TABLE products.catalog
(
    id             SERIAL PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    description    TEXT         NOT NULL,
    category       TEXT CHECK (category IN ('coffee', 'mug', 't-shirt')),
    price          NUMERIC(10, 2),
    stock_quantity INT CHECK (stock_quantity >= 0)
);

-- 제품 리뷰 테이블 생성하기
CREATE TABLE products.reviews
(
    id          BIGSERIAL PRIMARY KEY,
    product_id  INT,
    customer_id INT,
    review      TEXT,
    rank        SMALLINT
);

-- 제품 삽입하기
INSERT INTO products.catalog(name, description, category, price, stock_quantity)
VALUES ('Sunrise Blend', 'A smooth and balanced blend with notes of caramel and citrus', 'coffee', 14.99, 50),
       ('Midnight Roast', 'A dark roast with rich flavors of chocolate and toasted nuts', 'coffee', 16.99, 50),
       ('Morning Glory', 'A light roast with bright acidity and floral notes', 'coffee', 13.99, 30),
       ('Sunrise Brew Co. Mug', 'A ceramic mug with the Sunrise Brew Co. logo', 'mug', 9.99, 100),
       ('Sunrise Brew Co. T-Shirt', 'A soft cotton t-shirt with the Sunrise Brew Co. logo', 't-shirt', 19.99, 25);

-- 삽입한 제품 확인
SELECT id,
       name,
       price
FROM products.catalog;

-- 데이터 가져오기
SELECT id,
       name,
       price
FROM products.catalog
WHERE category = 'coffee';

-- 제품 가격 수정
UPDATE
    products.catalog
SET price = 16.54
WHERE id = 1;

-- 상품 삭제
DELETE
FROM products.catalog
WHERE id = 2;

-- 상품 조회
SELECT id,
       name,
       price,
       stock_quantity
FROM products.catalog;

