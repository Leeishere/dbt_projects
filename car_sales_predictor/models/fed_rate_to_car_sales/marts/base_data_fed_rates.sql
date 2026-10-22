{{ config(materialized='view') }}

select
    e_.observation_date,
    e_.effective_rate,
    f_.four_year_installment
from
    {{ref('effective_rate_fed_rates')}} as e_
left join
    {{ref('four_year_fed_rates')}} as f_
on
    e_.observation_date = f_.observation_date
