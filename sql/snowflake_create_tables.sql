use database olist_database;
use schema bronze;

create table if not exists customers (
    customer_id               VARCHAR PRIMARY KEY,
    customer_unique_id        VARCHAR NOT NULL,
    customer_zip_code_prefix  VARCHAR,
    customer_city             VARCHAR,
    customer_state            VARCHAR
);

create table if not exists sellers (
    seller_id               VARCHAR PRIMARY KEY,
    seller_zip_code_prefix  VARCHAR,
    seller_city             VARCHAR,
    seller_state            VARCHAR
);

create table if not exists product_category_name_translation (
    product_category_name          VARCHAR PRIMARY KEY,
    product_category_name_english  VARCHAR
);

create table if not exists products (
    product_id                  VARCHAR PRIMARY KEY,
    product_category_name       VARCHAR,
    product_name_lenght         INTEGER,
    product_description_lenght  INTEGER,
    product_photos_qty          INTEGER,
    product_weight_g            DECIMAL(10,2),   -- peso em gramas, pode chegar a dezenas de milhares
    product_length_cm           DECIMAL(7,2),    -- dimensões em cm, poucas centenas no máximo
    product_height_cm           DECIMAL(7,2),
    product_width_cm            DECIMAL(7,2)
);

create table if not exists orders (
    order_id                        VARCHAR PRIMARY KEY,
    customer_id                     VARCHAR REFERENCES customers(customer_id),
    order_status                    VARCHAR,
    order_purchase_timestamp        TIMESTAMP,
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP
);

create table if not exists order_items (
    order_id            VARCHAR REFERENCES orders(order_id),
    order_item_id       INTEGER,
    product_id          VARCHAR REFERENCES products(product_id),
    seller_id           VARCHAR REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

create table if not exists order_payments (
    order_id             VARCHAR REFERENCES orders(order_id),
    payment_sequential   INTEGER,
    payment_type         VARCHAR,
    payment_installments INTEGER,
    payment_value        DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

create table if not exists order_reviews (
    review_id               VARCHAR,
    order_id                VARCHAR REFERENCES orders(order_id),
    review_score            INTEGER,
    review_comment_title    VARCHAR,
    review_comment_message  VARCHAR,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

create table if not exists geolocation (
    geolocation_zip_code_prefix STRING,
    geolocation_lat             DECIMAL(10,7),   -- latitude: -90 a 90, com casas decimais de precisão GPS
    geolocation_lng             DECIMAL(10,7),   -- longitude: -180 a 180
    geolocation_city            STRING,
    geolocation_state           STRING
);