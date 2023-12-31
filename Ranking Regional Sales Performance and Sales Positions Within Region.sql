--Issue:
    --You are given a dataset that captures daily sales amounts from various regions. Your task is to rank the regions based on the date they achieved their highest sales and then rank the sales within each region.
    
    --The daily_sales table is structured as follows:
    
    --id (integer): A unique identifier for each record.
    --region_id (integer): The identifier of the region where the sales occurred.
    --sale_date (date): The date the sales took place.
    --sales_amount (float): The sales amount for that particular day in the given region.
    --Write a SQL query that produces the following output:
    
    --region_id (integer): The identifier of the region.
    --sale_date (date): The date the sales took place.
    --sales_amount (float): The sales amount for that particular day in the given region.
    --sales_rank_within_region (integer): A rank assigned to each sale amount within its specific region. The highest sales for each region receive a rank of 1. If there's a tie in sales amount, we should rank by most recent sale date.
    --earliest_top_sale_rank (integer): Rank of the regions based on the earliest date they achieved their highest sales (i.e., the sales with rank 1). In case two or more regions achieve their highest sales on the same date, the region with the bigger region_id should come first
    --We can assume that the region_id and sale_date combination will always be unique. The final output should be ordered first by earliest_top_sale_rank, then by sales_rank_within_region - both in ascending order.




--Initial Resolution:
    select i.*,
        DENSE_RANK() OVER(ORDER BY j.sale_date ASC, j.region_id DESC) earliest_top_sale_rank
           
    from(
        select region_id,
               sale_date,
               sales_amount,
               RANK() OVER(PARTITION BY region_id ORDER BY sales_amount DESC, sale_date DESC) sales_rank_within_region
        from daily_sales
      ) i
      
      inner join (
        select region_id,
               max(sales_amount),
               sale_date,
               row_number() OVER(PARTITION BY region_id ORDER BY max(sales_amount) DESC) row_order
        from daily_sales
        group by region_id, sale_date
      ) j on i.region_id = j.region_id and row_order = 1
    ORDER BY earliest_top_sale_rank ASC, sales_rank_within_region ASC;


--Simpler Solution:
    SELECT region_id, sale_date, sales_amount,
        DENSE_RANK() OVER (PARTITION BY region_id ORDER BY sales_amount DESC, sale_date DESC) AS sales_rank_within_region,
        DENSE_RANK() OVER (ORDER BY max_date, region_id DESC) AS earliest_top_sale_rank
    FROM daily_sales
    NATURAL JOIN (SELECT DISTINCT ON (region_id) region_id, sale_date AS max_date FROM daily_sales ORDER BY region_id, sales_amount DESC) t
    ORDER BY earliest_top_sale_rank, sales_rank_within_region;
