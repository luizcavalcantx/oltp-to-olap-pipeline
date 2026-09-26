with source as (
    select *
    from {{ source('bronze','product_category_name_translation') }}
),

ajust as (
    select
        lower(product_category_name) as product_category_name,
        lower(product_category_name_english) as product_category_name_english
    from source
)

select * from ajust