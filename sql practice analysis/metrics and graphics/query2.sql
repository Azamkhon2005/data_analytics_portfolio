/*
Calculation of :
1.Increase in the number of new users.
2.Increase in the number of new couriers.
3.Increase in the total number of users.
4.Increase in the total number of couriers.
*/
with prep1 as (SELECT date,
                      count(courier_id) as new_couriers,
                      coalesce(sum(count(courier_id)) OVER (ORDER BY date),
                               count(courier_id)) as total_couriers
               FROM   (SELECT courier_id,
                              min(time)::date as date
                       FROM   courier_actions
                       GROUP BY courier_id) sub1
               GROUP BY date
               ORDER BY date), prep2 as (SELECT date,
                                 count(user_id) as new_users,
                                 coalesce(sum(count(user_id)) OVER (ORDER BY date), count(user_id)) as total_users
                          FROM   (SELECT user_id,
                                         min(time)::date as date
                                  FROM   user_actions
                                  GROUP BY user_id) sub2
                          GROUP BY date
                          ORDER BY date)
SELECT prep1.date,
       new_users,
       new_couriers,
       total_users::int,
       total_couriers::int ,
       round(new_users*100/lag(new_users, 1) OVER(ORDER BY prep1.date)::decimal-100,
             2) as new_users_change,
       round(new_couriers*100/lag(new_couriers, 1) OVER (ORDER BY prep1.date)::decimal-100,
             2) as new_couriers_change,
       round(total_users*100/lag(total_users, 1) OVER(ORDER BY prep1.date)::decimal-100,
             2) as total_users_growth,
       round(total_couriers*100/lag(total_couriers, 1) OVER(ORDER BY prep1.date)::decimal-100,
             2) as total_couriers_growth
FROM   prep1
    INNER JOIN prep2
        ON prep1.date = prep2.date