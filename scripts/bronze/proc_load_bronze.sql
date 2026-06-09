/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
--step-3: Develop SQL Load Scripts
--step-4: Create a stored procedure since the data can be updating on daily basis
create or alter procedure bronze.load_bronze as 
begin
	declare @start_time Datetime, @end_time Datetime;
	set @start_time = getdate();
	begin try
	print '======================================================================';
	print 'Loading Bronze Layer';
	print '======================================================================';

	print '-----------------------------------------------------------------------';
	print 'Loading CRM Tables';
	print '-----------------------------------------------------------------------';
	

	print '>>> Truncating Table: bronze.crm_cust_info';
	truncate table bronze.crm_cust_info;

	print '>>> Inserting data Into: bronze.crm_cust_info';
	bulk insert bronze.crm_cust_info
	from 'C:\SQL_Learnings\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
	with (
		Firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	
	select count(*) from bronze.crm_cust_info

	print '>>> Truncating Table: bronze.crm_prd_info';
	truncate table bronze.crm_prd_info

	print '>>> Inserting data Into: bronze.crm_prd_info';
	bulk insert bronze.crm_prd_info
	from 'C:\SQL_Learnings\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
	with (
		Firstrow = 2,
		fieldterminator = ',',
		tablock
	);

	select count(*) from bronze.crm_prd_info

	print '>>> Truncating Table: bronze.crm_sales_details';
	truncate table bronze.crm_sales_details

	print '>>> Inserting data Into: bronze.crm_sales_details';

	bulk insert bronze.crm_sales_details
	from 'C:\SQL_Learnings\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
	with (
		Firstrow = 2,
		fieldterminator = ',',
		tablock
	);

	select count(*) from bronze.crm_sales_details

	print '-----------------------------------------------------------------------';
	print 'Loading ERP Tables';
	print '-----------------------------------------------------------------------';
	
	print '>>> Truncating Table: bronze.erp_cust_az12';
	truncate table bronze.erp_cust_az12
	bulk insert bronze.erp_cust_az12
	from 'C:\SQL_Learnings\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
	with (
		Firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	select count(*) from bronze.erp_cust_az12

	print '>>> Truncating Table: bronze.erp_loc_a101';
	truncate table bronze.erp_loc_a101
	bulk insert bronze.erp_loc_a101
	from 'C:\SQL_Learnings\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
	with (
		Firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	select count(*) from bronze.erp_loc_a101

	print '>>> Truncating Table: bronze.erp_px_cat_g1v2';
	truncate table bronze.erp_px_cat_g1v2
	bulk insert bronze.erp_px_cat_g1v2
	from 'C:\SQL_Learnings\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
	with (
		Firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	select count(*) from bronze.erp_px_cat_g1v2
	end try
	begin catch
		print '======================================================================';
		print 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		print 'Error Message' + Error_message();
		print 'Error Message' + cast(Error_message() as nvarchar);
		print 'Error Message' + cast(Error_state() as nvarchar);
		print '======================================================================';
	end catch
	set @end_time = getdate();
	print'>> Total Duration to load bronze layer : ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
end

exec bronze.load_bronze
