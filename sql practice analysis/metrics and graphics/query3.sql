
/*
Calculation:
1.Number of paying users.
2.Number of active couriers.
3.The share of paying users in the total number of users 4.for the current day.
5. The share of active couriers in the total number of couriers for the current day.
*/
with prep1 as (SELECT date,
                      count(courier_id) as new_couriers,
                      coalesce(sum(count(courier_id)) OVER (ORDER BY date),
                               count(courier_id))::int as total_couriers
               FROM   (SELECT courier_id,
                              min(time)::date as date
                       FROM   courier_actions
                       GROUP BY courier_id) sub1
               GROUP BY date
               ORDER BY date), prep2 as (SELECT date,
                                 count(user_id) as new_users,
                                 coalesce(sum(count(user_id)) OVER (ORDER BY date),
                                          count(user_id))::int as total_users
                          FROM   (SELECT user_id,
                                         min(time)::date as date
                                  FROM   user_actions
                                  GROUP BY user_id) sub2
                          GROUP BY date
                          ORDER BY date), active_users_t as (SELECT time::date as date,
                                          count(distinct user_id) as paying_users
                                   FROM   user_actions
                                   WHERE  order_id not in (SELECT order_id
                                                           FROM   user_actions
                                                           WHERE  action = 'cancel_order')
                                   GROUP BY time::date), active_couriers_t as (SELECT time::date as date,
                                                   count(distinct courier_id) as active_couriers
                                            FROM   courier_actions
                                            WHERE  order_id not in (SELECT order_id
                                                                    FROM   user_actions
                                                                    WHERE  action = 'cancel_order')
                                            GROUP BY date)
SELECT active_users_t.date,
       paying_users,
       active_couriers,
       round((paying_users/total_users::decimal)*100, 2) as paying_users_share,
       round((active_couriers/total_couriers::decimal)*100, 2) as active_couriers_share
FROM   active_users_t
    LEFT JOIN active_couriers_t
        ON active_users_t.date = active_couriers_t.date
    LEFT JOIN prep1
        ON active_users_t.date = prep1.date
    LEFT JOIN prep2
        ON active_users_t.date = prep2.date
ORDER BY active_users_t.date