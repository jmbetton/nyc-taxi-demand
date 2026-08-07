WITH calendar AS (
    SELECT DISTINCT trip_date
    FROM fact_demand
),
zone_hours AS (
    SELECT DISTINCT pickup_zone_id, zone_name, borough, trip_hour
    FROM fact_demand
),
full_grid AS (
    SELECT
        zh.zone_name,
        zh.borough,
        zh.trip_hour,
        c.trip_date,
        COALESCE(f.trips, 0) AS trips
    FROM zone_hours zh
    CROSS JOIN calendar c
    LEFT JOIN fact_demand f
        ON  f.pickup_zone_id = zh.pickup_zone_id
        AND f.trip_hour      = zh.trip_hour
        AND f.trip_date      = c.trip_date
)
SELECT
    zone_name,
    borough,
    trip_hour,
    ROUND(AVG(trips), 2)                                 AS mean_trips,
    ROUND(STDDEV_SAMP(trips), 2)                         AS sd_trips,
    ROUND(STDDEV_SAMP(trips) / NULLIF(AVG(trips), 0), 3) AS coeff_of_variation
FROM full_grid
GROUP BY zone_name, borough, trip_hour
HAVING AVG(trips) >= 1
ORDER BY coeff_of_variation DESC;


-- Query 2: volatility decomposed — total vs. within-weekday (seasonally adjusted)
WITH calendar AS (
    SELECT DISTINCT trip_date
    FROM fact_demand
),
zone_hours AS (
    SELECT DISTINCT pickup_zone_id, zone_name, borough, trip_hour
    FROM fact_demand
),
full_grid AS (
    SELECT
        zh.zone_name,
        zh.borough,
        zh.trip_hour,
        c.trip_date,
        DAYNAME(c.trip_date)   AS day_of_week,
        COALESCE(f.trips, 0)   AS trips
    FROM zone_hours zh
    CROSS JOIN calendar c
    LEFT JOIN fact_demand f
        ON  f.pickup_zone_id = zh.pickup_zone_id
        AND f.trip_hour      = zh.trip_hour
        AND f.trip_date      = c.trip_date
),
within_weekday AS (
    SELECT
        zone_name,
        borough,
        trip_hour,
        day_of_week,
        AVG(trips)        AS mean_trips_wd,
        STDDEV_SAMP(trips) AS sd_trips_wd
    FROM full_grid
    GROUP BY zone_name, borough, trip_hour, day_of_week
)
SELECT
    zone_name,
    borough,
    trip_hour,
    ROUND(AVG(mean_trips_wd), 2)                                  AS mean_trips,
    ROUND(SQRT(AVG(sd_trips_wd * sd_trips_wd)), 2)                AS within_wd_sd,
    ROUND(SQRT(AVG(sd_trips_wd * sd_trips_wd))
          / NULLIF(AVG(mean_trips_wd), 0), 3)                     AS within_wd_cv
FROM within_weekday
GROUP BY zone_name, borough, trip_hour
HAVING AVG(mean_trips_wd) >= 1
ORDER BY within_wd_cv DESC;