-- Creating the database
create database if not exists olist_database;
use olist_database;

--creating the schemas on database
create schema if not exists bronze;
create schema if not exists silver;
create schema if not exists gold;

-- creating AWS storage integration
-- Pro Snowflake me passar um iam_user_arn ou storage_aws_external_id ele precisa de uma role, mas pra eu criar uma role eu preciso do iam_user_arn, então por isso a gente cria primeiro com uma role ficticia para depois dar um alter para a role correta.
create storage integration if not exists aws_storage_integration
    type = external_stage
    storage_provider = 'S3'
    enabled = true
    storage_aws_role_arn = 'arn:aws:iam::924285052453:role/placeholder-role'
    storage_allowed_locations = ('s3://olist-oltp-olap/raw/');

describe integration aws_storage_integration;

-- iam_user_arn = arn:aws:iam::540730055093:user/2f292000-s
-- STORAGE_AWS_EXTERNAL_ID = TTC81378_SFCRole=4_JSd/eeJ4s/chRVCuWRvM3BFrLhs=

alter storage integration aws_storage_integration
    set storage_aws_role_arn = 'arn:aws:iam::924285052453:role/snowflake-olist-s3-role';

-- creating an external stage
use schema bronze;

create stage if not exists olist_s3_stage
    storage_integration = aws_storage_integration
    url = 's3://olist-oltp-olap/raw/'
    file_format = (type = parquet);

list @olist_s3_stage;

-- Creating the FILE FORMAT to extract the parquet files on S3
create file format parquet_ff TYPE = 'PARQUET';

-- Populating all the tables
copy into bronze.customers
from @olist_s3_stage/customers/ file_format = (format_name = parquet_ff)
match_by_column_name = case_insensitive;

copy into bronze.geolocation
from @olist_s3_stage/geolocation/ file_format = (format_name = parquet_ff)
match_by_column_name = case_insensitive;

TRUNCATE TABLE bronze.order_items;

COPY INTO bronze.order_items (
    order_id, order_item_id, product_id, seller_id,
    shipping_limit_date, price, freight_value
)
FROM (
    SELECT 
        $1:order_id::string,
        $1:order_item_id::number,
        $1:product_id::string,
        $1:seller_id::string,
        TO_TIMESTAMP_NTZ($1:shipping_limit_date::number, 6),
        $1:price::number(10,2),
        $1:freight_value::number(10,2)
    FROM @olist_database.bronze.olist_s3_stage/order_items/
)
FILE_FORMAT = (FORMAT_NAME = parquet_ff)
ON_ERROR = 'CONTINUE'
FORCE = TRUE;

copy into bronze.order_payments
from @olist_s3_stage/order_payments/ file_format = (format_name = parquet_ff)
match_by_column_name = case_insensitive;

TRUNCATE TABLE bronze.order_reviews;

COPY INTO bronze.order_reviews (
    review_id, order_id, review_score, review_comment_title,
    review_comment_message, review_creation_date, review_answer_timestamp
)
FROM (
    SELECT 
        $1:review_id::string,
        $1:order_id::string,
        $1:review_score::number,
        $1:review_comment_title::string,
        $1:review_comment_message::string,
        TO_TIMESTAMP_NTZ($1:review_creation_date::number, 6),
        TO_TIMESTAMP_NTZ($1:review_answer_timestamp::number, 6)
    FROM @olist_database.bronze.olist_s3_stage/order_reviews/
)
FILE_FORMAT = (FORMAT_NAME = parquet_ff)
ON_ERROR = 'CONTINUE'
FORCE = TRUE;

COPY INTO bronze.orders (
    order_id, customer_id, order_status,
    order_purchase_timestamp, order_approved_at,
    order_delivered_carrier_date, order_delivered_customer_date,
    order_estimated_delivery_date
)
FROM (
    SELECT 
        $1:order_id::string,
        $1:customer_id::string,
        $1:order_status::string,
        TO_TIMESTAMP_NTZ($1:order_purchase_timestamp::number, 6),
        TO_TIMESTAMP_NTZ($1:order_approved_at::number, 6),
        TO_TIMESTAMP_NTZ($1:order_delivered_carrier_date::number, 6),
        TO_TIMESTAMP_NTZ($1:order_delivered_customer_date::number, 6),
        TO_TIMESTAMP_NTZ($1:order_estimated_delivery_date::number, 6)
    FROM @olist_database.bronze.olist_s3_stage/orders/
)
FILE_FORMAT = (FORMAT_NAME = parquet_ff)
ON_ERROR = 'CONTINUE';

copy into bronze.product_category_name_translation
from @olist_s3_stage/product_category_name_translation/ file_format = (format_name = parquet_ff)
match_by_column_name = case_insensitive;

copy into bronze.products
from @olist_s3_stage/products/ file_format = (format_name = parquet_ff)
match_by_column_name = case_insensitive;

copy into bronze.sellers
from @olist_s3_stage/sellers/ file_format = (format_name = parquet_ff)
match_by_column_name = case_insensitive;