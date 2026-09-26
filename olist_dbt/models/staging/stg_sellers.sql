with source as (
    select *
    from {{ source('bronze','sellers') }}
),

ajust as (
    select
        seller_id,
        seller_zip_code_prefix::varchar as seller_zip_code_prefix,
        lower(seller_city) as seller_city,
        upper(seller_state) as seller_state
    from source
)

select * from ajust