with orders as (
    select * from {{ref('stg_orders')}}
),

delivery as (
    select * from {{ref('int_orders_delivery_metrics')}}
),

payments as (
    select * from {{ref('int_orders_payments_agg')}}
),

reviews as (
    select * from {{ref('int_orders_reviews_agg')}}
),

items as (
    select
        order_id,
        count(*) as total_items,
        sum(total_item_value) as order_total
    from {{ref('int_order_items_enriched')}}
    group by all
),

final as (
    select
        O.order_id,
        O.customer_id,
        O.order_status,
        O.order_purchase_timestamp,
        D.delivery_time_days,
        D.delivery_delay_days,
        D.is_late_delivery,
        P.total_payment_value,
        P.max_installments,
        R.average_score,
        I.total_items,
        I.order_total
    from orders as O
    left join delivery as D
        on o.order_id = d.order_id
    left join payments as P
        on O.order_id = P.order_id
    left join reviews as R
        on O.order_id = R.order_id
    left join items I
        on O.order_id = I.order_id
)

select * from final