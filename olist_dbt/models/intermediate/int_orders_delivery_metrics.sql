-- tempo de entrega (delivery_time_days), atraso vs estimado (delivery_delay_days) e uma flag booleana is_late_delivery.
-- Regra de negócio: só considerar pedidos com status delivered

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