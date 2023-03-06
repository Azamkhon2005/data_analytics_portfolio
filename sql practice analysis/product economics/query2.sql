/*
Calculation of:
1.Revenue per user (ARPU) for the current day.
2.Revenue per paying user (ARPPU) for the current day.
3.Order revenue, or average check (AOV) for the current day.
*/
with prep1 as (SELECT t1.date,
                      user_count,
                      paying_user_count,
                      orders_count
               FROM   (SELECT time::date as date,
                              count(distinct user_id) as user_count
                       FROM   user_actions
                       GROUP BY date) as t1
                   INNER JOIN (SELECT time::date as date,
                                      count(distinct user_id) as paying_user_count,
                                      count(distinct order_id) as orders_count
                               FROM   user_actions
                               WHERE  order_id not in (SELECT order_id
                                                       FROM   user_actions
                                                       WHERE  action = 'cancel_order')
                               GROUP BY date) as t2
                       ON t1.date = t2.date), prep2 as (SELECT date,
                                        sum(price) as revenue
                                 FROM   (SELECT date,
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
                                                                                 WHERE  action = 'cancel_order')) t3
                                                 ON products.product_id = t3.product_id) t4
                                 GROUP BY date)
SELECT prep1.date,
       round(revenue/user_count, 2) as arpu,
       round(revenue/paying_user_count, 2) as arppu,
       round(revenue/orders_count, 2) as aov
FROM   prep2
    INNER JOIN prep1
        ON prep2.date = prep1.date