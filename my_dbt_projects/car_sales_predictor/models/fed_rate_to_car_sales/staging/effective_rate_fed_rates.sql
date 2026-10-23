

{{ config(materialized='table') }}

with base as (
    select
        cast(observation_date as date) as observation_date,
        effective_rate
    from {{ source('fed_rate_data', 'effective_rate') }}
),
forward_filled as (
    select
        current_rate.observation_date,
        coalesce(current_rate.effective_rate, previous_rate.effective_rate)
            as effective_rate
    from base as current_rate
    left join lateral (
        select prior_rate.effective_rate
        from base as prior_rate
        where prior_rate.observation_date < current_rate.observation_date
          and prior_rate.effective_rate is not null
        order by prior_rate.observation_date desc
        limit 1
    ) as previous_rate on true
)
select
    observation_date,
    effective_rate
from forward_filled
where effective_rate is not null
;
