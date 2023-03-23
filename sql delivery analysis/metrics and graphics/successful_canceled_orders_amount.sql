/*
Calculation of:
1.The number of successful (delivered) orders.
2.The number of canceled orders.
3.The share of canceled orders in the total number of orders (cancel rate).
*/
SELECT hour,
       successful_orders,
       canceled_orders,
       round(canceled_orders::decimal / (successful_orders + canceled_orders),
             3) as cancel_rate
FROM   (SELECT date_part('hour', creation_time)::int as hour,
               count(order_id) as successful_orders
        FROM   orders
        WHERE  order_id not in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')
        GROUP BY hour) t1
    LEFT JOIN (SELECT date_part('hour', creation_time)::int as hour,
                      count(order_id) as canceled_orders
               FROM   orders
               WHERE  order_id in (SELECT order_id
                                   FROM   user_actions
                                   WHERE  action = 'cancel_order')
               GROUP BY hour) t2 using (hour)
ORDER BY hour