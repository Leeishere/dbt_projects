

{% set n_items 3 %}

with top_n as (
    select 
        lineitem.l_partkey qualified_keys,
        sum(lineitem.l_quantity) as total
        from {{ ref('tpch_lineitem') }} as lineitem
        group by lineitem.l_partkey
        order by sum(lineitem.l_quantity) desc
        limit {{ n_items }}
)

    select 
        region.r_name as Location,
        part.p_partkey as PartID,
        part.p_name as PartName,
        coalesce(sum(lineitem.l_quantity),0) as TotalCount
    
    from 
        {{ ref('tpch_lineitem') }} as lineitem
        left join 
        {{ ref('tpch_part') }} as part
        on 
        lineitem.l_partkey = part.p_partkey
        left join 
        {{ ref('tpch_orders') }} as orders
        on 
        lineitem.l_orderkey = orders.o_orderkey
        left join
        {{ ref('tpch_customer') }} as customer
        on
        orders.o_custkey = customer.c_custkey
        left join
        {{ ref('tpch_nation') }} as nation
        on
        customer.c_nationkey = nation.n_nationkey
        left join
        {{ ref('tpch_region') }} as region
        on
        nation.n_regionkey = region.r_regionkey
    where 
        part.p_partkey in (select qualified_keys from top_n)
    group by 
        region.r_name,
        part.p_partkey,
        part.p_name
    

/*
from {{ ref('tpch_customer') }} as customer
from {{ ref('tpch_region') }} as region
from {{ ref('tpch_lineitem') }} as lineitem
from {{ ref('tpch_nation') }} as nation
from {{ ref('tpch_orders') }} as orders
from {{ ref('tpch_part') }} as part
from {{ ref('tpch_partsupp') }} as partsupp
from {{ ref('tpch_supplier') }} as supplier
*/