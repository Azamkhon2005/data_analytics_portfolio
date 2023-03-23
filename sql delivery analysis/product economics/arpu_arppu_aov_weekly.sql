/*
This time we calculated the metrics not just by days, but by days of the week.
Calculation of:
1. Revenue per user (ARPU).
2. Revenue per Paying User (ARPPU).
3. Revenue Per Order (AOV).
*/
with prep1 as (SELECT t1.weekday_number,
                      t1.weekday,
                      user_count,
                      paying_user_count,
                      orders_count
               FROM   (SELECT date_part('isodow', time::date) as weekday_number,
                              to_char(time::date,'Day') as weekday,
                              count(distinct user_id) as user_count
                       FROM   user_actions
                       WHERE  time::date between '2022-08-26'
                          and '2022-09-08'
                       GROUP BY 1, 2) as t1
                   INNER JOIN (SELECT date_part('isodow', time::date) as weekday_number,
                                      to_char(time::date,'Day') as weekday,
                                      count(distinct user_id) as paying_user_count,
                                      count(distinct order_id) as orders_count
                               FROM   user_actions
                               WHERE  order_id not in (SELECT order_id
                                                       FROM   user_actions
                                                       WHERE  action = 'cancel_order')
                                  and time::date between '2022-08-26'
                                  and '2022-09-08'
                               GROUP BY 1, 2) as t2 using(weekday)), prep2 as (SELECT weekday,
                                                       weekday_number,
                                                       sum(price) as revenue
                                                FROM   (SELECT weekday,
                                                               weekday_number,
                                                               order_id,
                                                               products.product_id ,
                                                               price
                                                        FROM   products
                                                            INNER JOIN (SELECT date_part('isodow', creation_time::date) as weekday_number,
                                                                               to_char(creation_time::date,'Day') as weekday,
                                                                               order_id,
                                                                               unnest(product_ids) as product_id
                                                                        FROM   orders
                                                                        WHERE  order_id not in (SELECT order_id
                                                                                                FROM   user_actions
                                                                                                WHERE  action = 'cancel_order')
                                                                           and creation_time::date between '2022-08-26'
                                                                           and '2022-09-08') t3
                                                                ON products.product_id = t3.product_id) t4
                                                GROUP BY 1, 2)
SELECT prep1.weekday,
       prep1.weekday_number,
       round(revenue/user_count, 2) as arpu,
       round(revenue/paying_user_count, 2) as arppu,
       round(revenue/orders_count, 2) as aov
FROM   prep1
    INNER JOIN prep2 using(weekday_number);