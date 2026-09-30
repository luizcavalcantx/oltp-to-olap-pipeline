{{ config(severity='warn') }}

select
    order_id,
    order_status,
    order_delivered_customer_date
from {{ref('stg_orders')}}
where 1=1
    and order_status = 'delivered'
    and order_delivered_customer_date is null