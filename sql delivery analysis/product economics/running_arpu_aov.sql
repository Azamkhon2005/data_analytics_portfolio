/*
Calculation of:
1.Accumulated revenue per user (Running ARPU).
2.Accumulated revenue per paying user (Running ARPPU).
3.The accumulated revenue from the order, or the average check (Running AOV).
*/
with prep_new_users as (SELECT date ,
                               sum(count(user_id)) OVER(ORDER BY date) as new_users
                        FROM   (SELECT user_id,
                                       min(time::date) as date
                                FROM   user_actions
                                GROUP BY user_id) first_time
                        GROUP BY date
                        ORDER BY date), prep_new_paying_users as (SELECT date ,
                                                 sum(count(user_id)) OVER(ORDER BY date) as new_paying_users
                                          FROM   (SELECT user_id,
                                                         min(time::date) as date
                                                  FROM   user_actions
                                                  WHERE  order_id not in (SELECT order_id
                                                                          FROM   user_actions
                                                                          WHERE  action = 'cancel_order')
                                                  GROUP BY user_id) first_time
                                          GROUP BY date
                                          ORDER BY date), prep_count_orders as (SELECT date,
                                             sum(count(user_id)) OVER(ORDER BY date) as count_orders
                                      FROM   (SELECT order_id,
                                                     user_id,
                                                     min(time::date) as date
                                              FROM   user_actions
                                              WHERE  order_id not in (SELECT order_id
                                                                      FROM   user_actions
                                                                      WHERE  action = 'cancel_order')
                                              GROUP BY user_id, order_id) as prep_orders
                                      GROUP BY date), prep_total_price as (SELECT date,
                                            sum(sum(price)) OVER(ORDER BY date) as total_price
                                     FROM   products
                                         INNER JOIN (SELECT date,
                                                            unnest(product_ids) as product_id
                                                     FROM   orders
                                                         INNER JOIN (SELECT order_id,
                                                                            user_id,
                                                                            min(time::date) as date
                                                                     FROM   user_actions
                                                                     WHERE  order_id not in (SELECT order_id
                                                                                             FROM   user_actions
                                                                                             WHERE  action = 'cancel_order')
                                                                     GROUP BY user_id, order_id) as prep_orders using(order_id)) as prep_products using(product_id)
                                     GROUP BY date)
SELECT prep_total_price.date,
       round(total_price/new_users, 2) as running_arpu,
       round(total_price/new_paying_users, 2) as running_arppu,
       round(total_price/count_orders, 2) as running_aov
FROM   prep_total_price
    INNER JOIN prep_new_users using(date)
    INNER JOIN prep_new_paying_users using(date)
    INNER JOIN prep_count_orders using(date)