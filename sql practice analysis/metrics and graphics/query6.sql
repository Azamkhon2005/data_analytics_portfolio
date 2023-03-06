/*Calculation of :
1.The number of paying users per active courier.
2.The number of orders per active courier.
*/
SELECT t1.date,
       round(total_users/total_couriers::decimal, 2) as users_per_courier,
       round(total_orders/total_couriers::decimal, 2) as orders_per_courier
FROM   (SELECT time::date as date ,
               count(distinct courier_id) as total_couriers
        FROM   courier_actions
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY date) as t1
    INNER JOIN (SELECT time::date as date ,
                       count(distinct user_id) as total_users,
                       count(distinct order_id) as total_orders
                FROM   user_actions
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')
                GROUP BY date) as t2
        ON t1.date = t2.date
ORDER BY date