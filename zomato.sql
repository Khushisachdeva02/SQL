USE APR3;
select * from zom_order_deliveries;
-- Order_ID, Delivery_Date, Delivery_Time, Delivery_tip
select * from zom_orders;
-- Order_ID, User_ID, Res_ID, Food_Item_ID,Oty, Discount, Driver_ID, Delivery_Charges, Order_TIme, Order_Date, ETA
select * from zom_ratings;
-- Orde_ID, Ratings 
select * from zom_res;
-- Res_ID, RName, RAdress, RMobile 
select * from zom_res_menu;
-- Res_ID, Food_Type, Food_Category, Food_Item_Name, FOod_Item_ID, Prices, Zom_Price  
select * from zom_payments;	
-- Order_ID, Payment_Mode, Status 
select * from zom_users;
-- User_Id, UName, Email, Address, Mobile

# Zomato Exercise

# Amount based Anlaysis

-- 1) Find Overall Zomato Earning
# zomato_earning = ((food_item2_zomato_price*qty) + (food_item7_price*qty))*118%
# - discount + delivery_charges + delivery_tip 

-- select sum(a.Tip) from (select
-- Order_ID,
-- MAX(Discount) as Tip
-- from zom_orders o
-- group by 1
-- ) as a;

with cte as 
(select 
	o.Order_ID, 
    o.Food_Item_ID,
    od.Delivery_tip,
    o.Qty,
    o.Discount,
    o.Delivery_Charges,
    zr.Zom_Price,
    o.Qty*zr.Zom_Price as price
	from zom_orders as o
    
    join zom_order_deliveries as od
    on od.Order_ID=o.Order_ID

    join zom_res_menu as zr
    on zr.Food_Item_ID = o.Food_Item_ID),
summarized_orders as (
select
Order_ID,
sum(price)*1.18 as price,
max(Discount) as Discount,
max(Delivery_Charges) as Delivery_Charges,
max(Delivery_Tip) as Delivery_Tip
from cte
group by 1
)
select
sum(price)+sum(Delivery_Charges)+sum(Delivery_Tip)-sum(Discount) as earnings
from summarized_orders;




-- 2) Find Month wise Zomato Earning

with cte as 
(select 
	o.Order_ID, 
    o.Food_Item_ID,
    CONCAT(MONTHNAME(o.Order_Date)," ",YEAR(o.Order_Date)) AS omy,
    o.Order_Date,
    od.Delivery_tip,
    o.Qty,
    o.Discount,Delivery_Charges,
    zr.Zom_Price,
    o.Qty*zr.Zom_Price as price
	from zom_orders as o
    
    left join zom_order_deliveries as od
    on od.Order_ID=o.Order_ID
	
    
    left join zom_res_menu as zr
    on zr.Food_Item_ID = o.Food_Item_ID
    order by o.Order_Date),
summarized_orders as (
select
omy,
Order_ID,
Order_Date,
sum(price)*1.18 as price,
max(Discount) as Discount,
max(Delivery_Charges) as Delivery_Charges,
max(Delivery_Tip) as Delivery_Tip
from cte
group by 1,2,3
order by Order_Date
)
select
omy as Order_Month_Year,
sum(price)+sum(Delivery_Charges)+sum(Delivery_Tip)-sum(Discount) as earnings
from summarized_orders
group by 1;

-- 3) Find MOM % percnatge change in Zomato Earning.
with cte as 
(select 
	o.Order_ID, 
    o.Food_Item_ID,
    CONCAT(MONTHNAME(o.Order_Date)," ",YEAR(o.Order_Date)) AS omy,
    o.Order_Date,
    od.Delivery_tip,
    o.Qty,
    o.Discount,Delivery_Charges,
    zr.Zom_Price,
    o.Qty*zr.Zom_Price as price
	from zom_orders as o
    
    left join zom_order_deliveries as od
    on od.Order_ID=o.Order_ID

    left join zom_res_menu as zr
    on zr.Food_Item_ID = o.Food_Item_ID
    order by o.Order_Date),
summarized_orders as (
select
omy,
Order_ID,
Order_Date,
sum(price)*1.18 as price,
max(Discount) as Discount,
max(Delivery_Charges) as Delivery_Charges,
max(Delivery_Tip) as Delivery_Tip
from cte
group by 1,2,3
order by Order_Date
),
final_cte as(
select
omy as Order_Month_Year,
min(Order_Date) minOid,
sum(price)+sum(Delivery_Charges)+sum(Delivery_Tip)-sum(Discount) as earnings
from summarized_orders
group by 1)
Select
*,
CONCAT(ROUND(((earnings- lag(earnings) over (order by minOid))/(lag(earnings) over (order by minOid)))*100,2),'%') as MOM_Percent
from final_cte
order by minOid;


-- 4) Find Overall Res Earning

with cte as 
(select 
	o.Order_ID, 
    zr.RName,
    o.Food_Item_ID,
    od.Delivery_tip,
    o.Qty,
    o.Discount,
    Delivery_Charges,
    zrm.Prices,
    o.Qty*zrm.Prices as price
	from zom_orders as o
    
    left join zom_order_deliveries as od
    on od.Order_ID=o.Order_ID

	left join zom_res_menu as zrm
    on zrm.Food_Item_ID = o.Food_Item_ID
    
    left join zom_res as zr
    on zr.Res_ID = zrm.Res_ID
    ),
summarized_orders as (
select
RName,
Order_ID,
sum(price)*1.18 as price
-- max(Discount) as Discount,
-- max(Delivery_Charges) as Delivery_Charges,
-- max(Delivery_Tip) as Delivery_Tip
from cte
group by 1,2
)
select
RName,
sum(price) as earnings
from summarized_orders
group by 1;

-- 5) Find Month wise Res Earning

with cte as 
(select
	RName,
	o.Order_ID, 
    o.Food_Item_ID,
    CONCAT(MONTHNAME(o.Order_Date)," ",YEAR(o.Order_Date)) AS omy,
    o.Order_Date,
    od.Delivery_tip,
    o.Qty,
    o.Discount,Delivery_Charges,
    zrm.Zom_Price,
    o.Qty*zrm.Zom_Price as price
	from zom_orders as o
    
    left join zom_order_deliveries as od
    on od.Order_ID=o.Order_ID

    left join zom_res_menu as zrm
    on zrm.Food_Item_ID = o.Food_Item_ID
    
    left join zom_res as zr
    on zr.Res_ID = zrm.Res_ID
    order by o.Order_Date),
summarized_orders as (
select
RName,
omy,
Order_ID,
Order_Date,
sum(price)*1.18 as price,
max(Discount) as Discount,
max(Delivery_Charges) as Delivery_Charges,
max(Delivery_Tip) as Delivery_Tip
from cte
group by 1,2,3,4
order by Order_Date
)
select
RName,
omy as Order_Month_Year,
sum(price)+sum(Delivery_Charges)+sum(Delivery_Tip)-sum(Discount) as earnings
from summarized_orders
group by 1,2
order by RName,omy;


-- 6) Find MOM % percentage change in Zomato Earning.

-- 7) Find Res wise Zomato earning.

-- 8) Find Res wise Res earning.

with cte as 
(select
	RName,
	o.Order_ID, 
    o.Food_Item_ID,
    CONCAT(MONTHNAME(o.Order_Date)," ",YEAR(o.Order_Date)) AS omy,
    o.Order_Date,
    od.Delivery_tip,
    o.Qty,
    o.Discount,Delivery_Charges,
    zrm.Prices,
    o.Qty*zrm.Prices as price
	from zom_orders as o
    
    left join zom_order_deliveries as od
    on od.Order_ID=o.Order_ID

    left join zom_res_menu as zrm
    on zrm.Food_Item_ID = o.Food_Item_ID
    
    left join zom_res as zr
    on zr.Res_ID = zrm.Res_ID
    order by o.Order_Date),
summarized_orders as (
select
RName,
omy,
Order_ID,
Order_Date,
sum(price)*1.18 as price,
max(Discount) as Discount,
max(Delivery_Charges) as Delivery_Charges,
max(Delivery_Tip) as Delivery_Tip
from cte
group by 1,2,3,4
order by Order_Date
)
select
RName,
omy as Order_Month_Year,
sum(price)+sum(Delivery_Charges)+sum(Delivery_Tip)-sum(Discount) as earnings
from summarized_orders
group by 1,2
order by RName,omy;


-- 9) Find Food_type wise Zomato earning.

with cte as 
(select
	RName,
	o.Order_ID, 
    o.Food_Item_ID,
    CONCAT(MONTHNAME(o.Order_Date)," ",YEAR(o.Order_Date)) AS omy,
    o.Order_Date,
    od.Delivery_tip,
    o.Qty,
    zrm.Food_Type,
    o.Discount,Delivery_Charges,
    zrm.Prices,
    o.Qty*zrm.Zom_Price as price
	from zom_orders as o
    
    left join zom_order_deliveries as od
    on od.Order_ID=o.Order_ID

    left join zom_res_menu as zrm
    on zrm.Food_Item_ID = o.Food_Item_ID
    
    left join zom_res as zr
    on zr.Res_ID = zrm.Res_ID
    order by o.Order_Date),
summarized_orders as (
select
Food_Type,
omy,
Order_ID,
Order_Date,
sum(price)*1.18 as price,
max(Discount) as Discount,
max(Delivery_Charges) as Delivery_Charges,
max(Delivery_Tip) as Delivery_Tip
from cte
group by 1,2,3,4
order by Order_Date
)
select
Food_Type,
-- omy as Order_Month_Year,
sum(price)+sum(Delivery_Charges)+sum(Delivery_Tip)-sum(Discount) as earnings
from summarized_orders
group by 1
order by Food_Type;


-- 10) Find Food_type wise Res earning.

with cte as 
(select
	RName,
	o.Order_ID, 
    o.Food_Item_ID,
    CONCAT(MONTHNAME(o.Order_Date)," ",YEAR(o.Order_Date)) AS omy,
    o.Order_Date,
    od.Delivery_tip,
    o.Qty,
    zrm.Food_Type,
    o.Discount,Delivery_Charges,
    zrm.Prices,
    o.Qty*zrm.Prices as price
	from zom_orders as o
    
    left join zom_order_deliveries as od
    on od.Order_ID=o.Order_ID

    left join zom_res_menu as zrm
    on zrm.Food_Item_ID = o.Food_Item_ID
    
    left join zom_res as zr
    on zr.Res_ID = zrm.Res_ID
    order by o.Order_Date),
summarized_orders as (
select
Food_Type,
omy,
Order_ID,
Order_Date,
sum(price)*1.18 as price,
max(Discount) as Discount,
max(Delivery_Charges) as Delivery_Charges,
max(Delivery_Tip) as Delivery_Tip
from cte
group by 1,2,3,4
order by Order_Date
)
select
Food_Type,
sum(price)+sum(Delivery_Charges)+sum(Delivery_Tip)-sum(Discount) as earnings
from summarized_orders
group by 1
order by Food_Type;


-- 11) Find payment mode wise Zomato earning.
select * from zom_payments;

with cte as 
(select
	RName,
    zp.Payment_Mode,
	o.Order_ID, 
    o.Food_Item_ID,
    CONCAT(MONTHNAME(o.Order_Date)," ",YEAR(o.Order_Date)) AS omy,
    o.Order_Date,
    od.Delivery_tip,
    o.Qty,
    zrm.Food_Type,
    o.Discount,Delivery_Charges,
    zrm.Zom_Price,
    o.Qty*zrm.Zom_Price as price
	from zom_orders as o
    
    left join zom_order_deliveries as od
    on od.Order_ID=o.Order_ID
    
    left join zom_payments as zp
    on zp.Order_ID = o.Order_ID

    left join zom_res_menu as zrm
    on zrm.Food_Item_ID = o.Food_Item_ID
    
    left join zom_res as zr
    on zr.Res_ID = zrm.Res_ID
    order by o.Order_Date),
summarized_orders as (
select
Payment_Mode,
omy,
Order_ID,
Order_Date,
sum(price)*1.18 as price,
max(Discount) as Discount,
max(Delivery_Charges) as Delivery_Charges,
max(Delivery_Tip) as Delivery_Tip
from cte
group by 1,2,3,4
order by Order_Date
)
select
Payment_Mode,
sum(price)+sum(Delivery_Charges)+sum(Delivery_Tip)-sum(Discount) as earnings
from summarized_orders
group by 1
order by Payment_Mode;


-- 12) Find payment mode wise Res earning.

with cte as 
(select
	RName,
    zp.Payment_Mode,
	o.Order_ID, 
    o.Food_Item_ID,
    CONCAT(MONTHNAME(o.Order_Date)," ",YEAR(o.Order_Date)) AS omy,
    o.Order_Date,
    od.Delivery_tip,
    o.Qty,
    zrm.Food_Type,
    o.Discount,Delivery_Charges,
    zrm.Prices,
    o.Qty*zrm.Prices as price
	from zom_orders as o
    
    left join zom_order_deliveries as od
    on od.Order_ID=o.Order_ID
    
    left join zom_payments as zp
    on zp.Order_ID = o.Order_ID

    left join zom_res_menu as zrm
    on zrm.Food_Item_ID = o.Food_Item_ID
    
    left join zom_res as zr
    on zr.Res_ID = zrm.Res_ID
    order by o.Order_Date),
summarized_orders as (
select
Payment_Mode,
omy,
Order_ID,
Order_Date,
sum(price)*1.18 as price,
max(Discount) as Discount,
max(Delivery_Charges) as Delivery_Charges,
max(Delivery_Tip) as Delivery_Tip
from cte
group by 1,2,3,4
order by Order_Date
)
select
Payment_Mode,
sum(price)+sum(Delivery_Charges)+sum(Delivery_Tip)-sum(Discount) as earnings
from summarized_orders
group by 1
order by Payment_Mode;

select * from zom_order_deliveries;
select * from zom_orders;
select * from zom_res;
select * from zom_res_menu;
select * from zom_users;
select * from zom_payments;
select * from zom_ratings;

# Order Analysis
-- 1) Number of orders per month.
select * from zom_orders;
select monthname(Order_Date) as Months, count(distinct(Order_ID)) as Order_ID from zom_orders
group by Months;


-- 2) MOM percentage change in order.

select
*, 
concat(round(((Order_ID - (lag(Order_ID) over (order by minOid)))/ lag(Order_ID) over (order by minOid))*100,2),'%')  as Percent_Change 
from 
(select 
concat(monthname(Order_Date)," ",year(Order_Date)) as Months, 
min(Order_Date)as minOid, 
count(distinct(Order_ID)) as Order_ID 
from zom_orders
group by Months
order by minOid)dt;

-- months     minoid    order_id    %change
-- nov'23     01-11         29
-- dec'23     02-11         35
-- jan'24     01-01         33
-- feb'24     01-02         25

-- 3) Res wise order count.

select * from zom_orders;
select zo.Res_ID, zr.RName, count(Order_ID) as Count_Orders from zom_orders as zo
join zom_res as zr
on zo.res_ID = zr.Res_ID
group by Res_ID,RName; 



-- 4) Food catgeory wise order count.

select zrm.Food_Category, count(Order_ID) from zom_orders as zo
join zom_res_menu as zrm
on zo.res_ID = zrm.Res_ID
group by Food_Category; 

-- 5) Customers with most order.
select * from zom_orders;
SELECT 
    User_ID,
    COUNT(User_ID) AS total_orders
FROM 
    zom_orders
GROUP BY 
    User_ID
ORDER BY 
    total_orders DESC
LIMIT 1;

# Customer Analysis

-- 1) **Customers with repeat order.
Use apr3;

select 
User_ID,
count(Order_ID) as Repeat_Orders 
from
zom_orders
group by User_ID
having Repeat_Orders > 1
order by Repeat_Orders desc;

-- 2) **Customers with repeat order per month.

select 
User_ID,
count(Order_ID) as Repeat_Orders, 
monthname(Order_Date) as Months
from
zom_orders
group by User_ID, Months
having Repeat_Orders > 1
order by Repeat_Orders desc;

-- 3) **Customers with orders of multiple porducts.

SELECT 
    User_ID,
    Order_ID,
    COUNT(Food_Item_ID) AS Food_Item_Count
FROM 
    zom_orders
GROUP BY 
    User_ID, Order_ID
ORDER BY 
    Food_Item_Count DESC;

-- 4) **Customers with orders on consecutive days.

select * from zom_orders;
SELECT
    User_ID,
    Order_ID,
    DAY(Order_Date) AS Days,
    (DAY(Order_Date) - LAG(DAY(Order_Date)) OVER (ORDER BY DAY(Order_Date)))  AS Day_Difference
FROM
    zom_orders;

-- 5) **Customers with orders on consecutive days for multiple months.

SELECT
    User_ID,
    Order_ID,
    DAY(Order_Date) AS Days,
    month(Order_Date) as Months,
    (DAY(Order_Date) - LAG(DAY(Order_Date)) OVER (ORDER BY DAY(Order_Date)))  AS Day_Difference
FROM
    zom_orders
;

# Food_Type and catgeory Analysis
-- 1) Most order food_Type.
select 
Food_Type,
count(Food_Type) as Food_Count
from 
zom_res_menu
group by Food_Type
ORDER BY 
    Food_Count DESC
LIMIT 1;
-- 2) Most ordered food_category
Select
Food_Category,
count(Food_Category) as Food_Count
from 
zom_res_menu
group by Food_Category
ORDER BY 
    Food_Count DESC
LIMIT 1;

-- 3) Most order food_Type per Res
select
zr.RName, 
zrm.Food_Type,
count(Food_Type) as Food_Count
from 
zom_res_menu as zrm
left join 
zom_res as zr 
on 
zrm.Res_ID = zr.Res_ID
group by 
zr.RName,
zrm.Food_Type
ORDER BY 
    Food_Count DESC
LIMIT 1;
-- 4) Most ordered food_category per Res
select
zr.RName, 
zrm.Food_Category,
count(Food_Category) as Food_Count
from 
zom_res_menu as zrm
left join 
zom_res as zr 
on 
zrm.Res_ID = zr.Res_ID
group by 
zr.RName,
zrm.Food_Category
ORDER BY 
    Food_Count DESC
LIMIT 1;


# Delivery Analysis - Late,Early, Time
select * from zom_order_deliveries;
-- Order_ID, Delivery_Date, Delivery_Time, Delivery_tip
select * from zom_orders;
-- Order_ID, User_ID, Res_ID, Food_Item_ID,Oty, Discount, Driver_ID, Delivery_Charges, Order_TIme, Order_Date, ETA
SELECT
    zod.Order_ID,
    zo.ETA,
    zod.Delivery_Time,
    zo.Order_Time,
    CASE 
        WHEN TIMEDIFF(zod.Delivery_Time, zo.Order_Time) <= zo.ETA THEN 'On Time'
        ELSE 'Late'
    END AS Delivery_Status
FROM
    zom_order_deliveries AS zod
LEFT JOIN
    zom_orders AS zo
ON 
    zod.Order_ID = zo.Order_ID;