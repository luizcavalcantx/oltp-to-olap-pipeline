select
    order_id,
    round(sum(payment_value),2) as total_payment_value,
    count(distinct payment_type) as distinct_methods,
    max(payment_installments) as max_installments
from {{ ref('stg_order_payments') }}
group by order_id