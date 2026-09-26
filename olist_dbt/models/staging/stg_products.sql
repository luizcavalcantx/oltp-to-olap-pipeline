with source as (
    select *
    from {{ source('bronze','products') }}
),

ajust as (
    select
        product_id,
        lower(product_category_name) as product_category_name,
        product_name_lenght,
        product_description_lenght,
        product_photos_qty,
        product_weight_g::numeric(10,2) as product_weight_g,
        product_length_cm::numeric(10,2) as product_length_cm,
        product_height_cm::numeric(10,2) as product_height_cm,
        product_width_cm::numeric(10,2) as product_width_cm
    from source
)

select * from ajust