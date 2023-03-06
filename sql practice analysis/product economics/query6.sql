/*
Calculation of:
1.The total revenue received from the sale of this product for the entire period.
2.The share of revenue from the sale of this product in the total revenue received for the entire period.
*/
with prep as (SELECT name,
                     price
              FROM   (SELECT unnest(product_ids) as product_id
                      FROM   orders
                      WHERE  order_id not in (SELECT order_id
                                              FROM   user_actions
                                              WHERE  action = 'cancel_order')) t1
                  INNER JOIN products using(product_id))
SELECT product_name,
       sum(revenue) as revenue,
       sum(share_in_revenue) as share_in_revenue
FROM   (SELECT sum(price) as revenue,
               case when round(sum(price)*100/(SELECT sum(price)
                                        FROM   prep), 2) < 0.50 then 'ДРУГОЕ' else name end as product_name, round(sum(price)*100/(SELECT sum(price)
                                                                                                   FROM   prep), 2) as share_in_revenue
        FROM   prep
        GROUP BY name) t2
GROUP BY 1
ORDER BY 2 desc