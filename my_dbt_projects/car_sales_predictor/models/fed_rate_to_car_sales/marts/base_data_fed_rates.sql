{{ config(materialized='view') }}

-- One row per month: each source is normalized to the first of its month,
-- keeping the latest observation when a month has several.
with effective as (
    select
        cast(date_trunc('month', observation_date) as date) as observation_date,
        effective_rate,
        row_number() over (
            partition by date_trunc('month', observation_date)
            order by observation_date desc
        ) as rn
    from {{ ref('effective_rate_fed_rates') }}
),
four_year as (
    select
        cast(date_trunc('month', observation_date) as date) as observation_date,
        four_year_installment,
        row_number() over (
            partition by date_trunc('month', observation_date)
            order by observation_date desc
        ) as rn
    from {{ ref('four_year_fed_rates') }}
)
select
    e_.observation_date,
    e_.effective_rate,
    f_.four_year_installment
from effective as e_
left join four_year as f_
    on e_.observation_date = f_.observation_date
   and f_.rn = 1
where e_.rn = 1
