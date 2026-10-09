
select 
    l_orderkey,
    l_partkey,
    l_suppkey,
    l_linenumber,
    l_quantity,
    l_extendedprice
from
    samples.tpch.lineitem
where 
    l_returnflag != 'R'
;