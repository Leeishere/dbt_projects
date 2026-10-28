Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test

### Airflow data pipeline

Configure these environment variables for the Airflow scheduler and worker:

- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_PORT`, and
  `POSTGRES_HOST`: PostgreSQL connection settings.
- `FRED_API_KEY` and `FRED_URL`: FRED API credentials and endpoint.
- `FOUR_YEAR_INSTALLMENT` and `EFFECTIVE_RATE`: FRED series identifiers.

The default start date is not configured by an environment variable. The DAG
computes it as the first day of the month exactly four years before the
current month (`HISTORY_YEARS` in `dags/fed_rates_to_features_pipeline.py`),
and uses it as both the Airflow schedule start and the fetch default.

At task runtime, the fetch start month is recomputed from the existing data.
If neither source table has data, the computed default is used. If both do,
the fetch starts at the month of the older table's latest observation. If only
one has data, it starts that table's latest month minus `max_period + 1`
months (`max_period` is 3 for the quarterly series). The start month is
included in each fetch so late or revised observations can be upserted. Source
dates are normalized to the first of their month; a database check enforces
that date shape, and a unique index plus upsert ensures one row per month per
source table.


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
