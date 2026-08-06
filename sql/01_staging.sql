CREATE OR REPLACE VIEW stg_trips AS
SELECT
    tpep_pickup_datetime  AS pickup_ts,
    tpep_dropoff_datetime AS dropoff_ts,
    PULocationID          AS pickup_zone_id,
    trip_distance,
    fare_amount,
    tip_amount,
    total_amount
FROM read_parquet('data/raw/yellow_tripdata_*.parquet')
WHERE trip_distance > 0
  AND fare_amount   > 0
  AND total_amount  > 0
  AND tpep_dropoff_datetime > tpep_pickup_datetime
  AND PULocationID NOT IN (264, 265)                -- 264/265 = "Unknown" zones
  AND tpep_pickup_datetime >= DATE '2025-12-01'     -- clip stray out-of-window rows
  AND tpep_pickup_datetime <  DATE '2026-06-01';
