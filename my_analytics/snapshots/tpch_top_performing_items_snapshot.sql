


{% snapshot top_performing_items_snapshot %}

    {{ config(
        target_schema='snapshots',
        unique_key=['Location','PartID'],
        strategy='check',
        check_cols=['PriceRank', 'CountRank']
    ) }}

    SELECT * FROM {{ ref('tpch_top_performing_items') }}

{% endsnapshot %}