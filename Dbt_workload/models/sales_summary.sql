{{ config(materialized = 'table')}}

with source as (
    select * from {{ ref('stg_sales') }}
),


transformed as (
select 
country,
invoice_date,
round(cast(sum(quantity * unit_price) as numeric), 2) as total_sales,
count(distinct invoice_no) as num_invoices,
count(distinct customer_id) as num_customers
from source
group by country, invoice_date
)

select * from transformed 
