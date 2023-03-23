/*
Calculation of:
1.Number of new users.
2.Number of new couriers.
3.The total number of users for the current day.
4.The total number of couriers for the current day.
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
                          ORDER BY date)
SELECT prep1.date,
       new_users,
       new_couriers,
       total_users,
       total_couriers
FROM   prep1
    INNER JOIN prep2
        ON prep1.date = prep2.date


