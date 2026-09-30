select
    order_id,
    count(distinct review_id) as count_reviews,
    avg(review_score) as average_score,
    avg(datediff('day', review_creation_date, review_answer_timestamp)) as answer_time
from {{ ref('stg_order_reviews') }}
group by order_id