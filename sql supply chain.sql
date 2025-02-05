create database supply;
use supply;
create table supply_chain_view(
`Order Number` int,
Date datetime,
`Sku Number` varchar(30),
Quantity int,
Cost double,
Price double,
`Product Type` varchar(40),
`Product Family` varchar(40),
`Product Name` varchar(500),
`Store Name` varchar(50),
`Store Key` int,
`Store Region` varchar(20),
`Store State` varchar(20),
`Store City` text,
`Store Latitude` double,
`Store Longitude` double,
`Customer Name` text,
`Cust Key` int,
sales double,
day TEXT,
daily int);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\SQL Supply Chain View.csv'
INTO TABLE supply_chain_view
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
IGNORE 1 ROWS  ;

create table inventory_adjusted(
`Product Key` int,
`Product Name` varchar(500),
`Product Type` varchar(40),
`Product Family` varchar(40),
`Product Line` varchar(100),
`Product Group`varchar(100),
`Product Description` varchar(500),
`Sku Number` varchar(30),
Price double,
`Cost Amount` double,
`Quantity on Hand` int,
`Store State` varchar(20));

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\SQL F_INVENTORY_ADJUSTED.csv'
INTO TABLE inventory_adjusted
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
IGNORE 1 ROWS  
;

create table F_sales(
`Order Number` int,
`Cust Key` int,
`Store Key` int,
`Transaction Type`text,
Date datetime,
`Purchase Method` varchar(100));

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\SQL F_SALES.csv'
INTO TABLE F_sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
IGNORE 1 ROWS  
;


drop table supply_chain_view;
drop table inventory_adjusted;
drop table F_sales;
select * from supply_chain_view;
select * from inventory_adjusted;



select sum(sales)total from supply_chain_view;  #-------------------TOTAL SALES--------------------------------------

select distinct `Product Type`,sum(sales) from supply_chain_view  #------------PRODUCT WISE SALES------------------
group by 1 order by 1;

Select *,Cy-Py as diff,concat(round((Cy/py)*100,2),"%")`Diff_in_%`,#--------------SALES GROWTHPERCENTAGE-----------------------
round(concat(round((Cy/py)*100,2)-100,"%"),2)yetto
 from(
Select year(date)yrs,sum(sales)Cy,
lag(sum(sales)) over(order by Year(Date) asc)Py
 from supply_chain_view
group by 1 order by 1)abc;

select distinct year(Date) from supply_chain_view   #-------------------------YEAR-SALES---------------------------
order by 1;

select distinct daily,sum(sales)total  from supply_chain_view  #-------------------DAILY SALES TREND--------------------
group by 1
order by 1;

select distinct `Store Region`,sum(sales)total  from supply_chain_view  #-------------------REGION SALES --------------------
group by 1
order by 1;

select `Store Region`,                #----------------------------REGION-WISE SALES-----------------------------------
    SUM(sales) AS total_sales,
    ROUND((SUM(sales) / (select SUM(sales) from supply_chain_view) * 100), 2) as percentage_sales
from supply_chain_view
group by `Store Region`
order by `Store Region`;
    
    
select distinct `Store Name`,sum(sales)total  from supply_chain_view  #-------------------TOP 5 STORE SALES ---------------------
group by 1
order by 2 desc limit 5;
    
select  round(sum((Quantity*Cost)),2)inventoryvalue from supply_chain_view; #-------------------INVENTORY VALUE------------------

SELECT 
    -- MTD (Month-to-Date): From the first day of April 2023 to April 6, 2023
    SUM(CASE 
        WHEN DATE(`date`) >= DATE_FORMAT('2023-04-06', '%Y-%m-01') 
             AND DATE(`date`) <= '2023-04-06' THEN sales 
        ELSE 0 END) AS MTD_sales,

    -- QTD (Quarter-to-Date): From the first day of the current quarter to April 6, 2023
    SUM(CASE 
        WHEN DATE(`date`) >= DATE_FORMAT(DATE_SUB('2023-04-06', INTERVAL (MONTH('2023-04-06') - 1) % 3 MONTH), '%Y-%m-01') 
             AND DATE(`date`) <= '2023-04-06' THEN sales 
        ELSE 0 END) AS QTD_sales,

    -- YTD (Year-to-Date): From the first day of 2023 to April 6, 2023
    SUM(CASE 
        WHEN DATE(`date`) >= DATE_FORMAT('2023-04-06', '%Y-01-01') 
             AND DATE(`date`) <= '2023-04-06' THEN sales 
        ELSE 0 END) AS YTD_sales
FROM 
    supply_chain_view;  #---------------------------------------QTD,YTD,MTD--------------------------------------------------
    
    select sum(`Quantity on Hand`)quantityonhand from  inventory_adjusted;  #-----------------quantity-on-hand---------------

    SELECT 
    f.`Purchase Method`,
    SUM(sc.sales) AS Total_Sales,
    ROUND((SUM(sc.sales) / (SELECT SUM(sales) FROM supply_chain_view)) * 100, 2) AS Sales_Percentage
FROM 
    F_sales f
JOIN 
    supply_chain_view sc
ON 
    f.`Order Number` = sc.`Order Number`
    AND f.`Cust Key` = sc.`Cust Key`
    AND f.`Store Key` = sc.`Store Key`
GROUP BY 
    f.`Purchase Method`;  #--------------------------Purchase wise method sales-------------------------------------------------

























