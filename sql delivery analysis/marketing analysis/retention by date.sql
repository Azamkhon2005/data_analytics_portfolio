select date_trunc('month',start_date)::date as start_month,
    start_date,
    time::date-start_date as day_number,
    round(count(distinct user_id)::decimal / max(count(distinct user_id)) over(partition by start_date),2) as retention
        from (
            select user_id,min(time::date)  over( partition by user_id) as start_date, time  from user_actions) as t1
    group by start_date,time::date