--fact table : 실제 일어난 구매사건 기록하는 표
--dimension table : 고객, 상품, 날짜를 설명하는 표
--Grain은 “Fact table의 한 줄이 무엇을 의미하는가?”라는 뜻

--세dimension이 정상인지 먼저 확인 
SELECT 'dim_customer' AS table_name, COUNT(*) AS row_count
FROM dw.dim_customer

UNION ALL

SELECT 'dim_article', COUNT(*)
FROM dw.dim_article

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM dw.dim_date;


--빈 fact transactions 테이블 만들기 
--CREATE TABLE dw.fact_transactions :dw안에 fact transactions 라는 빈테이블을 만든다는뜻
--date_key INTEGER NOT NULL : 거래날짜를 숫자 key로 지정, 날짜는 비어있을수 없음 
--CHECK (sales_channel_id IN (1, 2)) : 채널번호에는 1또는 2만들어갈수 있게 
DROP TABLE IF EXISTS dw.fact_transactions;

CREATE TABLE dw.fact_transactions (
    date_key INTEGER NOT NULL,
    customer_key INTEGER NOT NULL,
    article_key INTEGER NOT NULL,
    price DOUBLE PRECISION NOT NULL,
    sales_channel_id SMALLINT NOT NULL,

    CONSTRAINT chk_sales_channel
        CHECK (sales_channel_id IN (1, 2))
);

SELECT COUNT(*)
FROM dw.fact_transactions;

   
--전체 거래 데이터를 fact table에 넣기 
--1.raw.transactions의 31,788,324개 거래를 읽는다.
--2.거래 날짜를 dim_date와 연결한다.
--3.고객 ID를 dim_customer와 연결한다.
--4.상품 ID를 dim_article과 연결한다.   
--5.짧은 Key를 fact_transactions에 저장한다.
    
INSERT INTO dw.fact_transactions (
    date_key,
    customer_key,
    article_key,
    price,
    sales_channel_id
)
SELECT
    d.date_key,
    c.customer_key,
    a.article_key,
    t.price,
    t.sales_channel_id

FROM raw.transactions AS t

JOIN dw.dim_date AS d
    ON d.full_date = t.t_dat

JOIN dw.dim_customer AS c
    ON c.customer_id = t.customer_id

JOIN dw.dim_article AS a
    ON a.article_id = t.article_id;


--raw와 fact 행수비교하기 

SELECT
    (SELECT COUNT(*)
     FROM raw.transactions) AS raw_transaction_rows,

    (SELECT COUNT(*)
     FROM dw.fact_transactions) AS fact_transaction_rows;
    
--fact tabl에는 숫자 Key만 있어서 그대로보면 의미를 알수없음 
SELECT *
FROM dw.fact_transactions
LIMIT 10;
    
--dimension과 다시 join해서 내용을 확인한다 
--dim date와 f.date key 연결....
SELECT
    d.full_date,
    LEFT(c.customer_id, 12) AS customer_id_sample,
    a.article_id,
    a.prod_name,
    a.product_group_name,
    f.price,
    f.sales_channel_id

FROM dw.fact_transactions AS f

JOIN dw.dim_date AS d
    ON d.date_key = f.date_key

JOIN dw.dim_customer AS c
    ON c.customer_key = f.customer_key

JOIN dw.dim_article AS a
    ON a.article_key = f.article_key

LIMIT 20;

--검색 속도를 위한 Index만들기
CREATE INDEX idx_fact_transactions_date
ON dw.fact_transactions (date_key);

CREATE INDEX idx_fact_transactions_customer_date
ON dw.fact_transactions (customer_key, date_key);

CREATE INDEX idx_fact_transactions_article_date
ON dw.fact_transactions (article_key, date_key);

--테이블 통계 업데이트 
--analyze : 테이블에 어떤값이 얼마나 있는지 PostgreSQL에 알려주는 작업,이 통계를 이용해 효율적인 aql실행방법을 알려준다 
ANALYZE dw.fact_transactions;

--Dimension과 Fact의 관계 등록하기, foreign key추가
ALTER TABLE dw.fact_transactions
ADD CONSTRAINT fk_fact_date
FOREIGN KEY (date_key)
REFERENCES dw.dim_date (date_key)
NOT VALID;

ALTER TABLE dw.fact_transactions
ADD CONSTRAINT fk_fact_customer
FOREIGN KEY (customer_key)
REFERENCES dw.dim_customer (customer_key)
NOT VALID;

ALTER TABLE dw.fact_transactions
ADD CONSTRAINT fk_fact_article
FOREIGN KEY (article_key)
REFERENCES dw.dim_article (article_key)
NOT VALID;
--not valid는 지금 다 검사하지 않고 관계를 먼저 등록한다는 뜻

SELECT 'dim_customer' AS table_name, COUNT(*) AS row_count
FROM dw.dim_customer

UNION ALL

SELECT 'dim_article', COUNT(*)
FROM dw.dim_article

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM dw.dim_date

UNION ALL

SELECT 'fact_transactions', COUNT(*)
FROM dw.fact_transactions;
