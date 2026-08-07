WITH trip_level AS (
    SELECT
        fare_amount,
        trip_distance,
        tip_amount,
        tip_amount / NULLIF(fare_amount, 0) AS tip_rate,
        NTILE(10) OVER (ORDER BY trip_distance) AS distance_decile
    FROM stg_trips
    WHERE fare_amount > 0
)
SELECT
    distance_decile,
    COUNT(*)                                        AS num_trips,
    ROUND(MIN(trip_distance), 2)                    AS min_miles,
    ROUND(MAX(trip_distance), 2)                    AS max_miles,
    ROUND(MEDIAN(trip_distance), 2)                 AS median_miles,
    ROUND(AVG(fare_amount), 2)                      AS avg_fare,
    ROUND(MEDIAN(tip_rate), 4)                      AS median_tip_rate,
    ROUND(QUANTILE_CONT(tip_rate, 0.25), 4)         AS tip_rate_p25,
    ROUND(QUANTILE_CONT(tip_rate, 0.75), 4)         AS tip_rate_p75
FROM trip_level
GROUP BY distance_decile
ORDER BY distance_decile;