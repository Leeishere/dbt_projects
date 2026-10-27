import os
from datetime import date, datetime, time, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

from dag_utils import (
    determine_api_call_start_date,
    dicts_of_params,
    first_day_of_month,
    import_multi_table_import_data,
    make_sql_db_params,
    update_frequencies,
)

# ----------------------------------------
# functions that manage imported variables and prep for the DAG
def _required_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise ValueError(f"Required environment variable {name} is not set.")
    return value


DEFAULT_OBSERVATION_START = _required_env(
    "FRED_DEFAULT_OBSERVATION_START"
)
SCHEDULE_START_DATE = first_day_of_month(
    date.fromisoformat(DEFAULT_OBSERVATION_START)
)
TABLE_NAMES = ["four_year_installment", "effective_rate"]
DATE_COLUMNS = {
    table_name: "observation_date"
    for table_name in TABLE_NAMES
}


def fetch_fed_rates_data() -> int:
    postgres_params = make_sql_db_params(
        dbname=_required_env("POSTGRES_DB"),
        user=_required_env("POSTGRES_USER"),
        password=_required_env("POSTGRES_PASSWORD"),
        port=int(_required_env("POSTGRES_PORT")),
        host=_required_env("POSTGRES_HOST"),
    )
    series_ids = {
        "four_year_installment": _required_env("FOUR_YEAR_INSTALLMENT"),
        "effective_rate": _required_env("EFFECTIVE_RATE"),
    }
    frequencies = update_frequencies(
        {
            "four_year_installment": "q",
            "effective_rate": "m",
        },
        old_freqs=[
            "d",
            "bw",
            "wef",
            "weth",
            "wew",
            "wetu",
            "wem",
            "wesu",
            "wesa",
            "bwew",
            "bwem",
        ],
        new_freq="m",
    )
    observation_start = determine_api_call_start_date(
        pg_df_params=postgres_params,
        default_date=DEFAULT_OBSERVATION_START,
        table_names=TABLE_NAMES,
        date_cols_for_table_names=DATE_COLUMNS,
    )
    api_params = dicts_of_params(
        keys_list=list(series_ids),
        ids_dict=series_ids,
        frequencies_dict=frequencies,
        api_key=_required_env("FRED_API_KEY"),
        observation_start=observation_start.isoformat(),
    )
    return import_multi_table_import_data(
        api_url=_required_env("FRED_URL"),
        dict_of_api_params=api_params,
        postgres_params=postgres_params,
        auto_rename_columns=True,
    )

# ---------------------------------------
# the DAG
default_args: dict[str, object] = {
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="fed_rates_dbt_pipeline",
    start_date=datetime.combine(SCHEDULE_START_DATE, time.min),
    schedule_interval="@monthly",
    default_args=default_args,
    catchup=True,                 ###  < ------------- FOR TESTING
    max_active_runs=1,
    is_paused_upon_creation=True  ###  < ------------- PAUSED FOR TESTING
) as dag:
    fetch_task = PythonOperator(
        task_id="fetch_fed_rates_data",
        python_callable=fetch_fed_rates_data,
    )

    dbt_task = BashOperator(
        task_id="run_dbt_models",
        bash_command=(
    'cd "$HOME/Projects/dbt_projects/my_dbt_projects/car_sales_predictor" && '
    '"$HOME/Projects/dbt_projects/.venv-dbt/bin/dbt" run --select '
    'effective_rate_fed_rates four_year_fed_rates base_data_fed_rates'
),
    )
    fetch_task.set_downstream(dbt_task)
