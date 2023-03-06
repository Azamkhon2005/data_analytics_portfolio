/*
Calculation of :
1.Income received on that day.
2.Revenue from new user orders received on that day.
3.The share of revenue from new user orders in the total revenue received for that day.
4.The share of revenue from orders of other users in the total revenue received for that day
*/
with new_users as (SELECT date ,
                          sum(price) as new_users_revenue
                   FROM   (SELECT t1.first as date,
                                  t1.user_id,
                                  order_id,
                                  unnest(product_ids) as product_id
                           FROM   user_actions
                               INNER JOIN (SELECT user_id,
                                                  min(time::date) as first
                                           FROM   user_actions
                                           GROUP BY user_id) t1
                                   ON user_actions.time::date = t1.first and
                                      user_actions.user_id = t1.user_id
                               INNER JOIN orders using(order_id)
                           WHERE  order_id not in (SELECT order_id
                                                   FROM   user_actions
                                                   WHERE  action = 'cancel_order')) t2
                       INNER JOIN products using(product_id)
                   GROUP BY date), total_revenue as (SELECT creation_time::date as date,
                                         sum(price) as revenue
                                  FROM   (SELECT creation_time,
                                                 unnest(product_ids) as product_id
                                          FROM   orders
                                          WHERE  order_id not in (SELECT order_id
                                                                  FROM   user_actions
                                                                  WHERE  action = 'cancel_order')) t3
                                      INNER JOIN products using(product_id)
                                  GROUP BY date)
SELECT total_revenue.date,
       revenue,
       new_users_revenue,
       round(new_users_revenue*100/revenue, 2) as new_users_revenue_share,
       100 - round(new_users_revenue*100/revenue, 2) as old_users_revenue_share
FROM   total_revenue
    INNER JOIN new_users using(date)
ORDER BY date