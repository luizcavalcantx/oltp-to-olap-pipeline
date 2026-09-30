select
    OP.order_id, 
    OP.payment_sequential,
    OP.payment_type,
    OP.payment_installments,
    OP.payment_value,
    O.order_status,
    O.order_purchase_timestamp
from {{ref('stg_order_payments')}} as OP
left join {{ref('stg_orders')}} as O
    on O.order_id = OP.order_id