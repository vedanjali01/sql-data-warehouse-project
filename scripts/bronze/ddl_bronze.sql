/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/
-- Create Database 'DataWarehouse'
USE master;

create database DataWareHouse;
Use DataWareHouse;

create schema bronze;
go
create schema silver;
go --go is a separator, which tells to execute one firsta and then move to next
create schema gold;
go

--step-2:
--Create Bronze layer DDL for table creation
if object_id ('bronze.crm_cust_info', 'U') is not null
	drop table bronze.crm_cust_info;
create table bronze.crm_cust_info(
	cst_id int,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date Date
);

if object_id ('bronze.crm_prd_info', 'U') is not null
	drop table bronze.crm_prd_info;
create table bronze.crm_prd_info(
	prd_id int,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost int,
	prd_line char(5),
	prd_start_dt Date,
	prd_end_dt Date
);

if object_id ('bronze.crm_sales_details', 'U') is not null
	drop table bronze.crm_sales_details;
create table bronze.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id int,
	sls_order_dt int,
	sls_ship_dt int,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price int
);
/*drop table bronze.erp_CUST_AZ12;
drop table bronze.erp_LOC_A101;
drop table bronze.erp_PX_CAT_G1V2;*/

if object_id ('bronze.erp_cust_az12', 'U') is not null
	drop table bronze.erp_cust_az12;
create table bronze.erp_cust_az12(
	CID NVARCHAR(50),
	BDATE date,
	GEN char(15)
);

if object_id ('bronze.erp_loc_a101', 'U') is not null
	drop table bronze.erp_loc_a101;
create table bronze.erp_loc_a101(
	CID Nvarchar(50),
	CNTRY Nvarchar(50)
);

if object_id ('bronze.erp_px_cat_g1v2', 'U') is not null
	drop table bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2(
	ID Nvarchar(50),
	CAT Nvarchar(50),
	SUBCAT Nvarchar(50),
	MAINTENANCE Nvarchar(50)
);

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
