show databases;
show schemas in database olist_database;
show warehouses;

use database olist_database;
use warehouse olist_warehouse;

-- creating a role
create role dbt_role;

-- creatin user
create user dbt_user
    password = 'dbtStrong123'
    default_role = dbt_role
    default_warehouse = olist_warehouse
    must_change_password = false;

-- grant role dbt to sysadmin
grant role dbt_role to role sysadmin;
grant role dbt_role to user dbt_user;

-- grant usage database and warehouse to dbt_role
grant usage on database olist_database to role dbt_role;
grant usage on warehouse olist_warehouse to role dbt_role;

-- grant usage on schemas
grant usage on schema bronze to role dbt_role;
grant select on all tables in schema olist_database.bronze to role dbt_role;

grant usage on schema olist_database.silver to role dbt_role;
grant create table on schema olist_database.silver to role dbt_role;
grant create view on schema olist_database.silver to role dbt_role;

grant usage on schema olist_database.gold to role dbt_role;
grant create table on schema olist_database.gold to role dbt_role;
grant create view on schema olist_database.gold to role dbt_role;

show grants to user dbt_user;