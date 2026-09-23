--Depending on what you need, this code is to help clean the data tables.  Remember, check with the team that owns the data before deleting rows or changing values.

	TRUNCATE TABLE TABLENAME;
				Insert into TABLENAME (
				Column Name 1,
        Column Name 2,
        )

      Select 
      Same Column Names and whatever you need to do to them
      From TABLENAME



--Example: Changes the Null values in the Country column to 'n/a'

	TRUNCATE TABLE gold.dim_customer;

				Insert into gold.dim_customer (
				customer_key,
				customer_id,
				customer_number,
				first_name,
				last_name,
				country,
				gender,
				marital_status,
				birthdate,
				create_date)

				Select
				customer_key,
				customer_id,
				customer_number,
				first_name,
				last_name,				
				Case when country is null then 'n/a'
				else country
				end country,
				gender,
				marital_status,
				birthdate,
				create_date
				from gold.dim_customers

Select * from gold.dim_customer
