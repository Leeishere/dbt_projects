
select
    o_orderkey,
    o_custkey
from
    samples.tpch.orders
where o_orderstatus = 'F'
;