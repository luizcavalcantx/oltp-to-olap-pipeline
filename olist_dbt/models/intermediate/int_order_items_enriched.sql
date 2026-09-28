select
    OI.order_id,
    OI.order_item_id,
    OI.product_id,
    OI.seller_id,
    OI.shipping_limit_date as shipping_limit_timestamp,
    OI.shipping_limit_date::date as shipping_limit_date,
    extract(hour from OI.shipping_limit_date) as shipping_limit_hour,
    OI.price,
    OI.freight_value,
    round((OI.price + OI.freight_value),2) as total_item_value,
    coalesce(PC.product_category_name_english, P.product_category_name) as product_category,
    P.product_weight_g,
    P.product_length_cm,
    P.product_height_cm,
    P.product_width_cm,
    S.seller_zip_code_prefix,
    S.seller_city,
    S.seller_state
from {{ ref('stg_order_items') }} as OI
left join {{ ref('stg_products') }} as P 
    on P.product_id = OI.product_id
left join {{ ref('stg_products_category') }} as PC 
    on PC.product_category_name = P.product_category_name
left join {{ ref('stg_sellers') }} as S 
    on S.seller_id = OI.seller_id