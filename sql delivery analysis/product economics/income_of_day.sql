/*
Calculation of :
1.income received on that day.
2.Total income for the current day.
3.The increase in the income received on this day in relation to the value of the previous day's income.
*/

with prep1 as (SELECT date,
                      order_id,
                      products.product_id ,
                      price
               FROM   products
                   INNER JOIN (SELECT creation_time::date as date,
                                      order_id,
                                      unnest(product_ids) as product_id
                               FROM   orders
                               WHERE  order_id not in (SELECT order_id
                                                       FROM   user_actions
                                                       WHERE  action = 'cancel_order')) t1
                       ON products.product_id = t1.product_id)
SELECT date,
       revenue,
       sum(revenue) OVER(ORDER BY date rows between unbounded preceding and current row) as total_revenue,
       round(revenue *100/(lag(revenue, 1) OVER(ORDER BY date)::decimal)-100,
             2) as revenue_change
FROM   (SELECT date,
               sum(price) as revenue
        FROM   prep1
        GROUP BY date
        ORDER BY date) t2