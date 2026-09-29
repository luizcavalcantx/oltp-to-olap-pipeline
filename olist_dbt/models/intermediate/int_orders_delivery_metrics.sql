select
    order_id,
    customer_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    datediff('day', order_purchase_timestamp, order_delivered_customer_date) as delivery_time_days,
    datediff('day', order_estimated_delivery_date, order_delivered_customer_date) as delivery_delay_days,
    order_delivered_customer_date > order_estimated_delivery_date as is_late_delivery
from {{ ref('stg_orders') }}
where 1=1
    and order_status = 'delivered'
    and order_delivered_customer_date is not null