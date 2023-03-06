/*
Calculation of :
1. The share of users who made only one order that day in the total number of paying users.
2. The share of users who made several orders that day in the total number of paying users.
*/
with prep as (SELECT time::date as date,
                     user_id,
                     count(order_id) as count_order
              FROM   user_actions
              WHERE  order_id not in (SELECT order_id
                                      FROM   user_actions
                                      WHERE  action = 'cancel_order')
              GROUP BY time::date, user_id)
SELECT date,
       round(count(distinct user_id) filter(WHERE count_order = 1)/count(distinct user_id)::decimal*100,
             2) as single_order_users_share,
       round(count(distinct user_id) filter(WHERE count_order > 1)/count(distinct user_id)::decimal*100,
             2) as several_orders_users_share
FROM   prep
GROUP BY date