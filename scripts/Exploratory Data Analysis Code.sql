        /* The data is in a view from the previous data warehouse project.  This will turn them into tables*/
        
        Select *
        Into gold.dim_customer
        from gold.dim_customers;
        
        Select *
        Into gold.dim_product
        from gold.dim_products;
        
        Select *
        Into gold.fact_sale
        from gold.fact_sales;
        
--Database Exploration:
        
        --Explore column values to determine dimensions and measures (things to aggregate) */
        
        Select *
        from gold.dim_customer;
        
        Select *
        from gold.dim_product;
        
        Select *
        from gold.fact_sale;
        
        --Explore All objects in the Database
        Select * from INFORMATION_SCHEMA.TABLES
        
        Select * FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_name = 'dim_customer'
        
        Select * FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_name = 'dim_product'
        
        Select * FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_name = 'fact_sale'
        
        
--Dimensions Exploration:
          Identifying the unique values (or categories) in each dimension.  
          Recognizing how data might be grouped or segmented, which is usefule for later analysis*/
         
         Select Distinct Country from gold.dim_customer
        
        
        
--Explore ALl Categories "The Major Divisions"
        Select Distinct category, subcategory, product_name from gold.dim_product
        
        
        ---Date Explorations
        --Explore boundaries (earliest and latest dates)
        
        Select
        MIN(order_date) as min_order, 
        Max(order_date) as max_order,
        DATEDIFF(year,min(order_date),max(order_date)) as order_range_years
        from gold.fact_sale
        
        --Find the oldest and youngest customer
        
        Select
        MIN(birthdate) as min_birth_date,
        Max(birthdate) as max_birth_date,
        DATEDIFF(year,MIN(birthdate),GETDATE()) as oldest_age,
        DATEDIFF(year,MAX(birthdate),GETDATE()) as youngest_age
        from gold.dim_customers
        
---Measure Exploration
        --Calculate the key metric of the business
        
        --Find the Total Sales
        
        Select sum(sales_amount) as total_sales from gold.fact_sale
        
        --Find how many items are sold
        
        Select sum(quantity) as total_quantity from gold.fact_sale
        
        --Find the average selling price
        
        Select AVG(price) as average_price from gold.fact_sale
        
        --Find the Median Sales Amount
        
        Select Distinct
        	Percentile_cont(0.5)
        		Within Group (Order by sales_amount)
        		Over () AS MedianSalesAmount
        	From gold.fact_sales
        
        --Find the Standard Deviation of the sales amount
        
        Select STDEVP(sales_amount) as stdDev_Sales_Amount
        	From gold.fact_sales
        
        --Find the Variance of the sales amount
        
        Select VAR(sales_amount) as variance_sales_amount from gold.fact_sale
        
        
        --Find the total number of orders
        --make sure to compare the count and distinct count, there might be repeats
        
        Select count(order_number) as total_orders from gold.fact_sale
        Select count(distinct order_number) as total_order_distinct from gold.fact_sale
        
        Select * from gold.fact_sale
        
        --Find the total number of products
        
        Select count(product_id) as total_products from gold.dim_product
        Select count(distinct product_id) as total_products from gold.dim_product
        
        --Find the total number of customers
        
        select count (customer_id) as total_customers from gold.dim_customer
        
        --Find the total number of customers that has placed an order
        select count (distinct customer_key) as total_customers from gold.fact_sales
        
        
        --Combining the searches above into one table
        Select 'Total Sales'as measure_name, sum(sales_amount) as measure_value from gold.fact_sale
        Union ALl
        Select 'Total Quantity', sum(quantity) as total_quantity from gold.fact_sale
        Union ALL
        Select 'Average Price', AVG(price) as average_price from gold.fact_sale
        Union All
        Select 'Total orders distinct', count(distinct order_number) as total_order_distinct from gold.fact_sale
        Union All
        Select 'Total products distinct', count(distinct product_id) as total_products from gold.dim_product
        Union All
        select 'Total customers', count(customer_id) as total_customers from gold.dim_customer
        --Union All
        --select 'Total customers placing orders', count (distinct customer_key) as total_customers_placed from gold.fact_sales
        Union All
        select top 1 'Median Sales Amount' as metric,
               MedianSalesAmount
        from (
            select percentile_cont(0.5) within group (order by sales_amount)
                   over () as MedianSalesAmount
            from gold.fact_sales
        ) t
        Union All
        Select 'Sales Amount Standard Deviation', STDEVP(sales_amount) as stdDev_Sales_Amount From gold.fact_sales
        Union All
        Select 'Sales Amount Variance', VAR(sales_amount) as variance_sales_amount from gold.fact_sale
        
--Magnitude
        --sum of measure by dimension
        
        --Find total cstomers by country
        Select country,
        count(customer_id) as total_customers
        from gold.dim_customer
        group by country
        order by total_customers DESC
        
        --Find total customers by gender
        Select
        gender,
        count(distinct customer_id) as total_customer
        from gold.dim_customer
        Group by gender
        order by total_customer DESC
        
        --Find total products by catgory
        Select
        category,
        count(distinct product_id) as total_products
        from gold.dim_product
        group by category
        order by total_products DESC
        
        --What is the average costs in each category?
        Select
        category,
        AVG(cost) as average_cost
        from gold.dim_product
        group by category
        order by average_cost DESC
        
        --What is the total revenue generated for each category?
        
        Select
        a.category,
        sum(b.sales_amount) as total_revenue
        from gold.dim_product a
        left join gold.fact_sale b
        on b.product_key = a.product_key
        group by category
        order by total_revenue DESC
        
        --Find total revenue is generated by each customer
        
        Select
        c.customer_key,
        c.first_name,
        c.last_name,
        sum(s.sales_amount) as total_revenue
        from gold.dim_customer c
        left join gold.fact_sale s
        on c.customer_key = s.customer_key
        group by c.customer_key,
        c.first_name,
        c.last_name
        Order by total_revenue Desc
        
        --What is the distribution of sold items across countries?
        
        Select
        c.country,
        sum(s.quantity) as items_sold
        from gold.dim_customer c
        left join gold.fact_sale s
        on c.customer_key = s.customer_key
        group by c.country
        order by items_sold Desc
        
 --Ranking
        --Order the values of dimensions by measure
        --Looking at the Top N and Bottom N values  will help find outliers
        
        
        --Which 5 products generate the highest revenue?
        
        Select top 5
        a.product_name,
        sum(b.sales_amount) as total_revenue
        from gold.fact_sale b
        left join gold.dim_product a
        on b.product_key = a.product_key
        group by a.product_name
        order by total_revenue DESC
        
        --same thing but using window functions
        
        Select *
        From (
        	Select
        	a.product_name,
        	sum(b.sales_amount) as total_revenue,
        	row_number() over (order by sum(b.sales_amount) DESC) AS rank_products
        	from gold.fact_sale b
        	left join gold.dim_product a
        	on b.product_key = a.product_key
        	group by a.product_name) t
        Where rank_products <= 5
        
        
        
        --What are the 5 worst-performing products in terms of sale?
        
        Select top 5
        a.product_name,
        sum(b.sales_amount) as total_revenue
        from gold.fact_sale b
        left join gold.dim_product a
        on b.product_key = a.product_key
        group by a.product_name
        order by total_revenue
        
        --Same thing but with a window function
        
        Select top 5 *
        From (
        	Select
        	a.product_name,
        	sum(b.sales_amount) as total_revenue,
        	row_number() over (order by sum(b.sales_amount) DESC) AS rank_products
        	from gold.fact_sale b
        	left join gold.dim_product a
        	on b.product_key = a.product_key
        	group by a.product_name) t
        order by rank_products DESC
        
        
        
        --Find the Top 10 customers who have generated the highest revenue
        
        Select top 10
        c.customer_key,
        c.first_name,
        c.last_name,
        sum(b.sales_amount) as total_revenue
        from gold.fact_sale b
        left join gold.dim_customer c
        on b.customer_key = c.customer_key
        group by 
        c.customer_key,
        c.first_name,
        c.last_name
        order by total_revenue DESC
        
        --Same thing but with window functions
        Select top 10
        c.customer_key,
        c.first_name,
        c.last_name,
        sum(b.sales_amount) as total_revenue,
        ROW_NUMBER() over(order by sum(b.sales_amount) DESC) as rank_customer
        from gold.fact_sale b
        left join gold.dim_customer c
        on b.customer_key = c.customer_key
        group by 
        c.customer_key,
        c.first_name,
        c.last_name
        order by rank_customer
        
        --Find the 3 customers with the fewest orders placed
        
        Select top 3
        c.customer_key,
        c.first_name,
        c.last_name,
        count(DISTINCT b.order_number) as total_orders
        from gold.fact_sale b
        left join gold.dim_customer c
        on b.customer_key = c.customer_key
        group by 
        c.customer_key,
        c.first_name,
        c.last_name
        order by total_orders
        
        --Showing time trend of a Country's Sales
        Select
        Year(order_date) as year,
        Month(order_date) as month,
        sum(sales_amount) Total_Sales
        from gold.dim_customer c
        Left Join gold.fact_sale s
        on s.customer_key = c.customer_key
        where country = 'United States'
        Group By 
        Year(order_date),
        Month(order_date)
        order by 
        Year(order_date),
        Month(order_date)
        
        
        --Finding the top 3 subcategories of each category by total sales.
        
        With ranked_sales as (
        Select
        p.category,
        p.subcategory,
        Sum(s.sales_amount) as total_sales,
        ROW_NUMBER() OVER(PARTITION BY category Order by SUM(sales_amount) DESC) as Rank_
        from gold.dim_product p
        left join gold.fact_sale s
        on p.product_key = s.product_key
        Group by
        p.category,
        p.subcategory
        --Order By
        --p.category,
        --Rank_,
        --subcategory,
        --total_sales
        )
        
        Select * from ranked_sales 
        where Rank_<=3
        
        
        
