with source as (
    select *
    from {{ source('bronze', 'customers') }}
),

ajust as (
    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix::varchar as zip_code_prefix,
        customer_city,
        upper(customer_state) as customer_state
    from source
)

select * from ajust