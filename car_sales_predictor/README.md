Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test

### Airflow data pipeline

Configure these environment variables for the Airflow scheduler and worker:

- `FRED_DEFAULT_OBSERVATION_START`: ISO date used when a source table is
  missing or has no observations, and as the stable Airflow schedule anchor.
- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_PORT`, and
  `POSTGRES_HOST`: PostgreSQL connection settings.
- `FRED_API_KEY` and `FRED_URL`: FRED API credentials and endpoint.
- `FOUR_YEAR_INSTALLMENT` and `EFFECTIVE_RATE`: FRED series identifiers.

At task runtime, the fetch watermark is recomputed using the lesser of the
latest observation dates in the two source tables (or the configured default
if either table has no observations). The selected month is included in each
fetch so late or revised observations can be upserted. Source dates are
normalized to the first of their month; a database check enforces that date
shape, and a unique index plus upsert ensures one row per month per source
table.


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
