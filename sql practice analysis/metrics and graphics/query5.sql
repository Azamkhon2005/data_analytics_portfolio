/*
Calculation:
1.Total number of orders.
2.Number of first orders (orders made by users for the first time).
3.Number of new user orders (orders placed by users on the same day they first used the service).
4. The share of the first orders in the total number of orders.
5. The share of new user orders in the total number of orders.
*/
with total_orders as (SELECT time::date as date,
                             count(order_id) as orders
                      FROM   user_actions
                      WHERE  order_id not in (SELECT order_id
                                              FROM   user_actions
                                              WHERE  action = 'cancel_order')
                      GROUP BY time::date), first_orders_t as (SELECT first_time as date,
                                                count(distinct user_id) as first_orders
                                         FROM   (SELECT user_id,
                                                        min(time)::date as first_time
                                                 FROM   user_actions
                                                 WHERE  order_id not in (SELECT order_id
                                                                         FROM   user_actions
                                                                         WHERE  action = 'cancel_order')
                                                 GROUP BY user_id) as t1
                                         GROUP BY first_time), first_visit as (SELECT user_id,
                                             min(time)::date as first
                                      FROM   user_actions
                                      GROUP BY user_id), new_users_orders_t as (SELECT date,
                                                 sum(orders)::int as new_users_orders
                                          FROM   (SELECT time::date as date,
                                                         user_id,
                                                         count(order_id) as orders
                                                  FROM   user_actions
                                                  WHERE  order_id not in (SELECT order_id
                                                                          FROM   user_actions
                                                                          WHERE  action = 'cancel_order')
                                                  GROUP BY time::date, user_id) as t3
                                              LEFT JOIN first_visit
                                                  ON t3.date = first_visit.first and
                                                     t3.user_id = first_visit.user_id
                                          WHERE  first_visit.user_id is not null
                                          GROUP BY date)
SELECT total_orders.date,
       orders,
       first_orders,
       new_users_orders,
       round(first_orders/orders::decimal*100, 2) as first_orders_share,
       round(new_users_orders/orders::decimal*100, 2) as new_users_orders_share
FROM   total_orders
    LEFT JOIN first_orders_t
        ON total_orders.date = first_orders_t.date
    LEFT JOIN new_users_orders_t
        ON total_orders.date = new_users_orders_t.date
ORDER BY total_orders.date