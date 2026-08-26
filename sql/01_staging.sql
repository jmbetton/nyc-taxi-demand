CREATE OR REPLACE VIEW stg_trips AS  -- OR REPLACE used for iteration and calling "stg_trips" many times
SELECT
    tpep_pickup_datetime  AS pickup_ts,  -- adding readable names
    tpep_dropoff_datetime AS dropoff_ts,
    PULocationID          AS pickup_zone_id,
    trip_distance,
    fare_amount,
    tip_amount,
    total_amount
FROM read_parquet('data/raw/yellow_tripdata_*.parquet')  -- Using DuckDB's read_parquet function with (*) to join all 6 parquet files
WHERE trip_distance > 0  -- Cleaning steps 
  AND fare_amount   > 0
  AND total_amount  > 0
  AND tpep_dropoff_datetime > tpep_pickup_datetime  -- Drop off / pickup time error
  AND PULocationID NOT IN (264, 265)  -- 264/265 = zones labeled as "Unknown"
  AND tpep_pickup_datetime >= DATE '2025-12-01'     
  AND tpep_pickup_datetime <  DATE '2026-06-01';
