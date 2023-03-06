/*average time to deliver a product*/
with prep1 as (SELECT courier_id,
                      order_id,
                      time as accept_time
               FROM   courier_actions
               WHERE  action = 'accept_order'
                  and order_id not in (SELECT order_id
                                    FROM   user_actions
                                    WHERE  action = 'cancel_order')), prep2 as (SELECT courier_id,
                                                   order_id,
                                                   time as delivered_time
                                            FROM   courier_actions
                                            WHERE  action = 'deliver_order'
                                               and order_id not in (SELECT order_id
                                                                 FROM   user_actions
                                                                 WHERE  action = 'cancel_order'))
SELECT date,
       round(avg(date_part)/60)::int as minutes_to_deliver
FROM   (SELECT accept_time::date as date,
               extract(epoch
        FROM   delivered_time-accept_time)
        FROM   prep1
            INNER JOIN prep2
                ON prep1.courier_id = prep2.courier_id and
                   prep1.order_id = prep2.order_id) as prep3
GROUP BY date