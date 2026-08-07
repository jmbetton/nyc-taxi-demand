SELECT
    day_of_week,
    trip_hour,
    SUM(trips)                             AS total_trips,
    COUNT(DISTINCT trip_date)              AS num_days,
    SUM(trips) / COUNT(DISTINCT trip_date) AS avg_trips_per_day
FROM fact_demand
GROUP BY day_of_week, trip_hour
ORDER BY
    CASE day_of_week
        WHEN 'Monday'    THEN 1
        WHEN 'Tuesday'   THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday'  THEN 4
        WHEN 'Friday'    THEN 5
        WHEN 'Saturday'  THEN 6
        WHEN 'Sunday'    THEN 7
    END,
    trip_hour;