WITH daily_zone AS (
    SELECT
        zone_name,
        borough,
        trip_date,
        SUM(trips) AS daily_trips
    FROM fact_demand
    GROUP BY zone_name, borough, trip_date
)
SELECT
    zone_name,
    borough,
    trip_date,
    daily_trips,
    AVG(daily_trips) OVER (
        PARTITION BY zone_name
        ORDER BY trip_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7d
FROM daily_zone
ORDER BY zone_name, trip_date;