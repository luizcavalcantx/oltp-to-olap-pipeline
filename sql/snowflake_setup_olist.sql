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