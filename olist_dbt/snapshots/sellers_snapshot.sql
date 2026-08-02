{% snapshot sellers_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='seller_id',
      strategy='check',
      check_cols=['seller_zip_code_prefix', 'seller_city', 'seller_state'],
    )
}}

SELECT * FROM {{ source('raw', 'sellers') }}

{% endsnapshot %}
