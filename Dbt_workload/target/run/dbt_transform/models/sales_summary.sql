
  
    

  create  table "staging"."bankole_store"."sales_summary__dbt_tmp"
  
  
    as
  
  (
    

with source as (
    select * from "staging"."bankole_store"."stg_sales"
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
  );
  