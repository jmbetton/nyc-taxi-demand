CREATE OR REPLACE TABLE fact_demand AS  
SELECT
    t.pickup_zone_id,
    z.Zone    AS zone_name,
    z.Borough AS borough,
    CAST(t.pickup_ts AS DATE)      AS trip_date,  -- CAST used to change data type
    EXTRACT(hour FROM t.pickup_ts) AS trip_hour,  -- EXTRACT used to isolate hour from pickup time
    DAYNAME(t.pickup_ts)           AS day_of_week,  -- DAYNAME extracts name of weekday from pickup time
    COUNT(*)             AS trips,
    SUM(t.total_amount)  AS revenue,
    AVG(t.fare_amount)   AS avg_fare,
    AVG(t.trip_distance) AS avg_distance,
    AVG(t.tip_amount / NULLIF(t.fare_amount, 0)) AS avg_tip_rate 
FROM stg_trips t
JOIN read_csv_auto('data/taxi_zone_lookup.csv') z
  ON t.pickup_zone_id = z.LocationID  -- Matching on zone ID
GROUP BY 1, 2, 3, 4, 5, 6;

