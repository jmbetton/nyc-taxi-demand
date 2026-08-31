# New York City Taxi Service Demand and Volatility

Work in Progress

I'm using this project to learn more advanced SQL through the analysis of New York yellow yaxi data. Specifically, answering the question of "what yellow taxi zones throughout New York experience high volatility beyond the expected weekend and rush hour spikes in activity.

The data was initially downloaded from the NYC Taxi and Limousine Commission website in Parquet format. I chose the date ranges to span the most recent 6 months of trip records which totals approximately 18 million trips from December 1st 2025 to May 31st 2026. The othe data set is the taxi zone lookup csv file which stores information such as zone ID, zone name, and Borough name for each of the 264 taxi zones (Really only 262 real zones because 263 and 264 are labels for unknown zones.)

This information is mainly here as an exercise for myself in articulating the purpose of each query and reasons for choosing certain logic. It also serves as a summary of the project work flow.

SQL Steps: An explanation of the 7 different SQL files, what the goal of the query is and for more complex queries, how the logic works. 

## 01_staging
- This SQL file creates an initial view (not physically saved) from the 6 original parquet files.
- Cleans names, and filters out N/A values and possible errors in data.

## 02_fact_demand
- This is where a real table that is saved to disk is created and used for future queries.
- The fact_demand table joins the staging view with the zone csv file and aggregates data.
- It collapses to rows that summaraize the total trips, avg fare, avg distance and avg tip rate for a given unique combination of zone, date and hour.
- Note: I used AVG(tip/fare) instead of summing all tips and all fares then dividing. This gives an average of ratios and paints a better picture of what the typical tip rate is regardless of trip fare.

## 03_seasonality
- This SQL query investigates how the trip demand or volume of trips, varies by different hours of each weekday
- Queries the fact_demand table and aggregates into a 7x24 grid showing total trips and average trips per day

## 04_moving_average
- Computes a 7-day moving average of daily trip-demand for each zone
- For each zone, every day within the 6-month time period has a rolling average of trips over the previous 6 days and including the current date.
- Purpose is to smooth out random daily zone spikes and identify which zones show a real increase in volume over some specified region of time.

## 05_Volatility
- This file is the most complex SQL file and contains two different queries so I will provide a more in depth summary. The goal is to analyze the volatility of each zone hour to understand which zone's have demand that is actually unpredictable at a certain time of day. So the question that arises is "what volatility metric should I use to accurately identify a specific zone-hour with unpredictable demand" i.e. demand spikes or dives that can't be predicted by expected commuter behavior or day-of-week trends. This will be answered later.
### Query 1
- First, what the query is actually doing:
    - This query uses 3 CTE's to compute the final values. CTE's are basically a temporary table that is build within a query and referenced later on in that same query. 
        1. calendar: Collapses the data into a row for each unique date across the 6-months of data. Creates a 182x1 grid each cell is a unique date.
        2. zone_hours: Creates a table with each unique zone hour that is included in the fact table. So it excludes any zone hour that for the 6-month period has 0 recorded trips. These are most likely the zones with quiet hours or hours of non-operation.
        3. full_grid: Combines the two previous CTE's into a table that has a row for every zone_hour for every calendar day. This join includes zone hours with no recorded trips and uses 0 fill to explicitly show there was 0 demand.
- The last part of the query is the actual calculation:
    - Average or expected daily demand for each zone hour.
    - Sample Standard Deviation of daily demand for each zone hour. Used sample SD, because I sampled 6-months.
    - Coefficient of Variation (SD/Mean): This partly answers the question posed earlier. It calculates volatility relative to expected demand for a certain zone hour. 
### Query 2
- This query is largely the same as the previous but the purpose is different and actually addresses the problem of predictable vs unpredictable variation in demand. Query 1 calculated volatility for each zone hour across every weekday, so even though the coefficient of variation was used to normalize relative to the expected demand for each zone hour, some of the volatility can be attributed to predictable week day patterns. For example, time square may be a volatile zone even when we control for its higher than average demand but this may very well be attributable to a predictable spike on weekends. So some of that volatility can't be considered true "risk" in the sense that it isn't unpredictable and it is actually able to be forecasted when taking into account cyclical weekday patterns. To account for this, Query 2 decomposes the volatility further. It isolates volatility on each weekday. From here, real obervations about unpredictable risk are able to be made.
- Changes to CTE's:
    1. The first CTE change is that day_of_week was added to full_grid so each observation now has a week day label.
    2. The second is the addition of a fourth CTE (within_weekday). Each zone now has a specific zone_hour for each weekday, EX: (Timesquare | 6 pm | Fridays). It then calculates an average and standard deviation for each weekday zone hour.
- Calculations:
    1. Recover overall average for each zone_hour from the collapsed within_weekday CTE.
    2. Average the standard deviations across the 7 weekdays for each zone hour. SD doesn't average linearly like total trips does, so it is squared first, then averaged, then the square root is taken to return back to SD.
    3. Compute Coefficient of Variance using the weekday adjusted SD.


    




