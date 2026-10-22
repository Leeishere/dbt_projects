{{ config(materialized='table') }}

select
    cast(observation_date as date) as observation_date,
    four_year_installment
from
    {{ source('fed_rate_data', 'four_year_installment') }}

where four_year_installment is not null
;