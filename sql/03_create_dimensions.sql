

--step1. 빈 dim customer 테이블 만들
--CREATE TABLE dw.dim_customer : dw 공간 안에 dim_customer라는 새 테이블을 만든다.
--고객마다 새로운 숫자를 자동으로만듬 
-- create table : 빈그릇 만들기, insert into : 그릇에 데이터넣기 
-- VARCHAR(64): 최대 64자리 문자

DROP TABLE IF EXISTS dw.dim_customer;

CREATE TABLE dw.dim_customer (
    customer_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id VARCHAR(64) NOT NULL UNIQUE,
    fn BOOLEAN,
    active BOOLEAN,
    club_member_status TEXT,
    fashion_news_frequency TEXT,
    age SMALLINT,
    age_group VARCHAR(20),
    postal_code VARCHAR(64)
);

--step2. raw 고객데이터를 새테이블에 넣기
--INSERT INTO dw.dim_customer : 정리한 데이터를 dim customer에 넣겠다
--raw.customers에서 고객 데이터를 가져와 정리한 뒤 dw.dim_customer에 넣어라.
--case는 excel의 if와 비슷 
INSERT INTO dw.dim_customer (
    customer_id,
    fn,
    active,
    club_member_status,
    fashion_news_frequency,
    age,
    postal_code
)
SELECT
    customer_id,

    CASE
        WHEN TRIM(COALESCE(fn, '')) IN ('1', '1.0') THEN TRUE
        WHEN TRIM(COALESCE(fn, '')) IN ('0', '0.0') THEN FALSE
        ELSE NULL
    END,

    CASE
        WHEN TRIM(COALESCE(active, '')) IN ('1', '1.0') THEN TRUE
        WHEN TRIM(COALESCE(active, '')) IN ('0', '0.0') THEN FALSE
        ELSE NULL
    END,

    NULLIF(TRIM(club_member_status), ''),

    CASE
        WHEN NULLIF(TRIM(fashion_news_frequency), '') IS NULL THEN 'None'
        ELSE INITCAP(LOWER(TRIM(fashion_news_frequency)))
    END,

    CASE
        WHEN NULLIF(TRIM(age), '') IS NULL THEN NULL
        ELSE ROUND(age::NUMERIC)::SMALLINT
    END,

    postal_code
FROM raw.customers;

--step 3 연령대 만들기
-- update는 이미들어있는 데이터를 수정하거나 채우는 명령이야 
UPDATE dw.dim_customer
SET age_group =
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END;

--행수확
SELECT COUNT(*) 
FROM dw.dim_customer;


--고객데이터 일부확인 
SELECT
    customer_key,
    customer_id,
    age,
    age_group,
    club_member_status,
    fashion_news_frequency
FROM dw.dim_customer
LIMIT 10;

--연령대별 고객 수 확인
SELECT
    age_group,
    COUNT(*) AS customer_count
FROM dw.dim_customer
GROUP BY age_group
ORDER BY age_group;


--dim article 만들기 
--article_key INTEGER GENERATED ALWAYS AS IDENTITY : PostgreSQL이 상품마다 1, 2, 3... 번호를 자동 생성한다.
DROP TABLE IF EXISTS dw.dim_article;

CREATE TABLE dw.dim_article (
    article_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    article_id VARCHAR(10) NOT NULL UNIQUE,
    product_code INTEGER,
    prod_name TEXT,
    product_type_no INTEGER,
    product_type_name TEXT,
    product_group_name TEXT,
    graphical_appearance_name TEXT,
    colour_group_name TEXT,
    perceived_colour_value_name TEXT,
    perceived_colour_master_name TEXT,
    department_no INTEGER,
    department_name TEXT,
    index_name TEXT,
    index_group_name TEXT,
    section_no INTEGER,
    section_name TEXT,
    garment_group_no INTEGER,
    garment_group_name TEXT,
    detail_desc TEXT
);

--이제 raw.articles에서 필요한 컬럼을 가져와 dw.dim_article에 넣는다.
INSERT INTO dw.dim_article (
    article_id,
    product_code,
    prod_name,
    product_type_no,
    product_type_name,
    product_group_name,
    graphical_appearance_name,
    colour_group_name,
    perceived_colour_value_name,
    perceived_colour_master_name,
    department_no,
    department_name,
    index_name,
    index_group_name,
    section_no,
    section_name,
    garment_group_no,
    garment_group_name,
    detail_desc
)
SELECT
    article_id,
    product_code,
    prod_name,
    product_type_no,
    product_type_name,
    product_group_name,
    graphical_appearance_name,
    colour_group_name,
    perceived_colour_value_name,
    perceived_colour_master_name,
    department_no,
    department_name,
    index_name,
    index_group_name,
    section_no,
    section_name,
    garment_group_no,
    garment_group_name,
    detail_desc
FROM raw.articles;

-- 결과확인 
SELECT COUNT(*)
FROM dw.dim_article;

--상품 10개를 확인해보자
SELECT
    article_key,
    article_id,
    prod_name,
    product_type_name,
    product_group_name,
    colour_group_name,
    department_name
FROM dw.dim_article
LIMIT 10;


--dim date table create
-- 빈날짜 테이블 만들
DROP TABLE IF EXISTS dw.dim_date;

CREATE TABLE dw.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year SMALLINT NOT NULL,
    quarter SMALLINT NOT NULL,
    month SMALLINT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    year_month VARCHAR(7) NOT NULL,
    week_of_year SMALLINT NOT NULL,
    day_of_month SMALLINT NOT NULL,
    day_of_week SMALLINT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

--모든 날짜 자동 생성하기 직접 입력안하고 
INSERT INTO dw.dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    year_month,
    week_of_year,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_key,
    d::DATE AS full_date,
    EXTRACT(YEAR FROM d)::SMALLINT AS year,
    EXTRACT(QUARTER FROM d)::SMALLINT AS quarter,
    EXTRACT(MONTH FROM d)::SMALLINT AS month,
    TO_CHAR(d, 'FMMonth') AS month_name,
    TO_CHAR(d, 'YYYY-MM') AS year_month,
    EXTRACT(WEEK FROM d)::SMALLINT AS week_of_year,
    EXTRACT(DAY FROM d)::SMALLINT AS day_of_month,
    EXTRACT(ISODOW FROM d)::SMALLINT AS day_of_week,
    TO_CHAR(d, 'FMDay') AS day_name,
    EXTRACT(ISODOW FROM d) IN (6, 7) AS is_weekend
FROM GENERATE_SERIES(
    (SELECT MIN(t_dat) FROM raw.transactions),
    (SELECT MAX(t_dat) FROM raw.transactions),
    INTERVAL '1 day'
) AS generated_dates(d);

-- SELECT MIN(t_dat) FROM raw.transactions : 가장오래된 거래일을 찾는다
-- SELECT MAX(t_dat) FROM raw.transactions : 가장 최근 거래일을 찾는다
-- EXTRACT(YEAR FROM d):날짜에서 연도를 꺼낸다 
-- EXTRACT(ISODOW FROM d) IN (6, 7) :요일 번호가 6,7 즉 토요일 일요일이면 true 로만든다 

SELECT COUNT(*)
FROM dw.dim_date;

--첫날짜와 마지막 날짜확인 
SELECT
    MIN(full_date) AS first_date,
    MAX(full_date) AS last_date
FROM dw.dim_date;

--날짜데이터 일부 확인
SELECT *
FROM dw.dim_date
ORDER BY full_date
LIMIT 10;

SELECT 'dim_customer' AS table_name, COUNT(*) AS row_count
FROM dw.dim_customer

UNION ALL

SELECT 'dim_article', COUNT(*)
FROM dw.dim_article

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM dw.dim_date;


