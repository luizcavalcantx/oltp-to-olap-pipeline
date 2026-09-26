with source as (
    select *
    from {{ source('bronze', 'geolocation') }}
),

ajust as (
    select
        GEOLOCATION_ZIP_CODE_PREFIX::varchar as geolocation_zip_code_prefix,
        geolocation_lat::numeric(10,7) as geolocation_lat,
        geolocation_lng::numeric(10,7) as geolocation_lng,
        lower(geolocation_city) as geolocation_city,
        upper(geolocation_state) as geolocation_state
    from source
)

select * from ajust