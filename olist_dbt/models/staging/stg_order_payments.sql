with source as (
    select *
    from {{ source('bronze','order_payments') }}
),

ajust as (
    select
        order_id,
        payment_sequential,
        lower(payment_type) as payment_type,
        payment_installments,
        payment_value::numeric(10,2) as payment_value
    from source
)

select * from ajust