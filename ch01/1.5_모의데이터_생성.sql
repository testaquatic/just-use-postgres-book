CREATE TABLE trades
(
    id             BIGINT,
    buyer_id       INTEGER,
    symbol         TEXT,
    order_quantity INTEGER,
    bid_price      NUMERIC(5, 2),
    order_time     TIMESTAMP
);

SELECT COUNT(*)
FROM trades;

SELECT generate_series(1, 5);

SELECT generate_series(1, 5) AS id;

SELECT id,
       random(1, 10) AS buyer_id
FROM generate_series(1, 5) AS id;

SELECT id,
       (ARRAY ['AAPL', 'MSFT', 'GOOG'])[random(1, 3)] AS symbol
FROM generate_series(1, 5) AS id;

INSERT INTO trades(id, buyer_id, symbol, order_quantity, bid_price, order_time)
SELECT id,
       random(1, 10)                                                AS buyer_id,
       (ARRAY ['AAPL', 'MSFT', 'GOOG', 'AMZN', 'FB'])[random(1, 5)] AS symbol,
       random(1, 1000)                                              AS order_quantity,
       round(random(10.00, 20.00), 2)                               AS bid_price,
       now()                                                        AS order_time
FROM generate_series(1, 1000) AS id;

SELECT id,
       buyer_id,
       symbol,
       order_quantity,
       bid_price,
       order_time
FROM trades
LIMIT 10;

SELECT COUNT(*)
FROM trades
WHERE symbol = 'AAPL';

SELECT symbol,
       COUNT(*) AS total_volume
FROM trades
GROUP BY symbol
ORDER BY total_volume DESC;

SELECT buyer_id,
       SUM(order_quantity * bid_price) AS total_value
FROM trades
GROUP BY buyer_id
ORDER BY total_value DESC
LIMIT 3;

