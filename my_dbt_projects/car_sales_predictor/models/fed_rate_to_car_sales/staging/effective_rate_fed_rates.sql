

{{ config(materialized='table') }}

with base as (
    select
        cast(observation_date as date) as observation_date,
        effective_rate
    from {{ source('fed_rate_data', 'effective_rate') }}
),
-- BECASUE WE CAPTURE PAD DATA AND KNOW NULL FREQUENCIES, THIS *CHEAP*, FILTERED APPROACH IS HOPED TO BE ADEQUATE
isna as (
    select * from base where effective_rate is null
),
ff_step_one as (
    select 
        isna.observation_date,
        base.observation_date as potential_candidate,
        base.effective_rate as potential_fill_value
    from
        isna
    cross join
        base
    where
        isna.observation_date > base.observation_date
    and
        base.effective_rate is not null
),
ff_step_two as (
    select 
        ff_step_one.observation_date,
        rank() over (partition by ff_step_one.observation_date order by ff_step_one.potential_candidate desc) as ranked_by_date,
        ff_step_one.potential_fill_value
    from ff_step_one
),
forward_filled as(
    select
        base.observation_date,
        case when base.effective_rate 
                is not null then 
                    base.effective_rate
                else
                    ff_step_two.potential_fill_value
                end as
                    effective_rate
    from 
        base
    left join
        ff_step_two
    on
        base.observation_date = ff_step_two.observation_date
    and 
        ff_step_two.ranked_by_date = 1
)
select 
    * 
from 
    forward_filled 
where 
    effective_rate is not null