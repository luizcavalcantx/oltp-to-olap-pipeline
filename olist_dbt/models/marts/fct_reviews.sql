select
    R.review_id,
    R.order_id,
    O.order_status,
    R.review_score,
    R.review_comment_title,
    R.review_comment_message,
    O.order_purchase_timestamp,
    R.review_creation_date,
    R.review_answer_timestamp,
    datediff('day', R.review_creation_date, R.review_answer_timestamp) as review_response_days
from {{ref('stg_order_reviews')}} as R
left join {{ref('stg_orders')}} as O
    on R.order_id = O.order_id