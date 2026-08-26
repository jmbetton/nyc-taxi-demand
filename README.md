## New York City Taxi Service Demand and Volatility

Work in Progress

I'm using this project to learn more advanced SQL through the analysis of New York yellow yaxi data. Specifically, answering the question of "what yellow taxi zones throughout New York experience high volatility beyond the expected weekend and rush hour spikes in activity.

The data was initially downloaded from the NYC Taxi and Limousine Commission website in Parquet format. I chose the date ranges to span the most recent 6 months of trip records which totals approximately 18 million trips from December 1st 2025 to May 31st 2026. The othe data set is the taxi zone lookup csv file which stores information such as zone ID, zone name, and Borough name for each of the 264 taxi zones (Really only 262 real zones because 263 and 264 are labels for unknown zones.)


SQL Steps

01_staging
- This SQL file creates an initial view (not physically saved) from the 6 original parquet files.
- Cleans names, and filters out N/A values and possible errors in data.



