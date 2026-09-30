select
    A.product_id,
    coalesce(B.product_category_name_english, A.product_category_name) as product_category_name,
    product_name_lenght as product_name_length,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
from {{ ref('stg_products') }} as A
left join {{ ref('stg_products_category') }} as B 
    on A.product_category_name = B.product_category_name