
{{ config(materialized='view') }}

{% set n_key_regions 5 %}


select 
    tpr.Location,
    coalesce(sum(tpr.TotalCount),0) as TotalTopItems,
    coalesce(sum(tpr.ExtendedPrice),0) as ExtendedPrice
from
    {{ ref('tpch_top_performing_items') }} as tpr
group by 
    tpr.Location
order by 
    sum(tpr.ExtendedPrice) desc,
    sum(tpr.TotalCount) desc,
    tpr.Location asc
limit
    {{ n_key_regions }}
;
