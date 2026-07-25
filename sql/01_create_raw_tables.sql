CREATE SCHEMA IF NOT EXISTS raw;

CREATE SCHEMA IF NOT EXISTS dw;

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS raw.articles (
    article_id VARCHAR(10),
    product_code INTEGER,
    prod_name TEXT,
    product_type_no INTEGER,
    product_type_name TEXT,
    product_group_name TEXT,
    graphical_appearance_no INTEGER,
    graphical_appearance_name TEXT,
    colour_group_code INTEGER,
    colour_group_name TEXT,
    perceived_colour_value_id INTEGER,
    perceived_colour_value_name TEXT,
    perceived_colour_master_id INTEGER,
    perceived_colour_master_name TEXT,
    department_no INTEGER,
    department_name TEXT,
    index_code TEXT,
    index_name TEXT,
    index_group_no INTEGER,
    index_group_name TEXT,
    section_no INTEGER,
    section_name TEXT,
    garment_group_no INTEGER,
    garment_group_name TEXT,
    detail_desc TEXT
);
-creat table : raw Schema 안에 articles라는 테이블을 만든다

CREATE TABLE IF NOT EXISTS raw.customers (
    customer_id VARCHAR(64),
    fn TEXT,
    active TEXT,
    club_member_status TEXT,
    fashion_news_frequency TEXT,
    age TEXT,
    postal_code VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS raw.transactions (
    t_dat DATE,
    customer_id VARCHAR(64),
    article_id VARCHAR(10),
    price DOUBLE PRECISION,
    sales_channel_id SMALLINT
);

SELECT *
FROM raw.articles
LIMIT 10;
--모든 컬럼, 10줄만 ,raw articles에서 

SELECT COUNT(*)
FROM raw.articles;
-- 전체 행수를 세는 명령어 

SELECT COUNT(*)
FROM raw.customers c ;

SELECT 'articles' AS table_name, COUNT(*) AS row_count
FROM raw.articles

UNION ALL

SELECT 'customers', COUNT(*)
FROM raw.customers

UNION ALL

SELECT 'transactions', COUNT(*)
FROM raw.transactions;

TRUNCATE TABLE raw.transactions;
--raw.transactions 테이블의 구조와 컬럼은 남겨두고, 안에 들어 있는 데이터만 전부 비워라.

SELECT COUNT(*)
FROM raw.transactions;