WITH weekly_zone AS (
    SELECT
        zone_name,
        borough,
        DATE_TRUNC('week', trip_date) AS week_start,
        SUM(trips) AS weekly_trips
    FROM fact_demand
    GROUP BY zone_name, borough, DATE_TRUNC('week', trip_date)
),
with_prior AS (
    SELECT
        zone_name,
        borough,
        week_start,
        weekly_trips,
        LAG(weekly_trips) OVER (
            PARTITION BY zone_name
            ORDER BY week_start
        ) AS prev_week_trips
    FROM weekly_zone
)
SELECT
    zone_name,
    borough,
    week_start,
    weekly_trips,
    prev_week_trips,
    ROUND(
        100.0 * (weekly_trips - prev_week_trips)
        / NULLIF(prev_week_trips, 0),
        1
    ) AS wow_growth_pct
FROM with_prior
ORDER BY zone_name, week_start;
