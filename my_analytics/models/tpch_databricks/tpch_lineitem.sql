
select 
    l_orderkey,
    l_partkey,
    l_supplykey,
    l_linenumber,
    l_quantity
from
    samples.tpch.lineitem
where 
    l_returnflag != 'R'
;