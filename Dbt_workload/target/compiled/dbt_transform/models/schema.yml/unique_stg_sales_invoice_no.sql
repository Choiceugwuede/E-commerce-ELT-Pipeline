
    
    

select
    invoice_no as unique_field,
    count(*) as n_records

from "staging"."bankole_store"."stg_sales"
where invoice_no is not null
group by invoice_no
having count(*) > 1


