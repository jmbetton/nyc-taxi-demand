import duckdb

# Connect to a database file, created on first run then reused after.
con = duckdb.connect("nyc_taxi.duckdb")

# Run the build-layer SQL files in order: staging view, then fact table.
for path in ["sql/01_staging.sql", "sql/02_fact_demand.sql"]:
    print(f"Running {path} ...")
    with open(path) as f:
        con.execute(f.read())

# Confirm it worked: how many rows landed in the fact table?
row_count = con.execute("SELECT COUNT(*) FROM fact_demand").fetchone()[0]
print(f"Done. fact_demand has {row_count:,} rows.")

con.close()
