{{ config(materialized = 'view') }}


with source as (
    select * from {{ source ('public', 'bankole_store') }}
),

staged as 
(
select
"InvoiceNo" as invoice_no,
trim("StockCode") as stock_code,
upper("Description") as description,
cast("Quantity" as int) as quantity,
cast(to_timestamp("InvoiceDate", 'MM/DD/YYYY HH24:MI') AS date) as invoice_date,
to_char(to_timestamp("InvoiceDate", 'MM/DD/YYYY HH24:MI'), 'HH24:MI') as invoice_time,
"UnitPrice" as unit_price,
"CustomerID" AS customer_id,
Upper("Country") as Country
from source
)

select * from staged