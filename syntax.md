Those expressions are **Jinja templating with dbt-specific functions**, embedded in your SQL. Start with the official [Jinja and macros guide](https://docs.getdbt.com/docs/build/jinja-macros), then try the [hands-on Jinja tutorial](https://docs.getdbt.com/guides/using-jinja). [dbt Developer Hub](https://docs.getdbt.com/docs/build/jinja-macros?utm_source=chatgpt.com)

Your two examples mean:

| Expression | Meaning | Reference |
|---|---|---|
| `{{ config(materialized='table') }}` | Tell dbt to build this model as a physical table. | [Model configurations](https://docs.getdbt.com/reference/model-configs) |
| `{{ ref('my_first_dbt_model') }}` | Resolve that model’s database object name and record a dependency on it. | [ref()](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) |

`config()` sets model configuration; `ref()` helps dbt determine model relationships and build order. [dbt Developer Hub](https://docs.getdbt.com/reference/dbt-jinja-functions/config?utm_source=chatgpt.com)

Learn these three Jinja forms first:

```jinja
{{ ... }}   -- Evaluate an expression
{% ... %}   -- Execute template logic, such as loops or conditionals
{# ... #}   -- Write a template comment
```

A complete model could look like:

```sql
{{ config(materialized='table') }}

select *
from {{ ref('my_first_dbt_model') }}
where id is not null
```

Put that in a **different model file**, such as `filtered_example.sql`, since a model should not reference itself.

For learning, compile it and inspect the generated SQL:

```bash
dbt compile --select filtered_example
```

Look under `target/compiled/` in your project. Seeing how dbt replaces the Jinja with database-specific SQL makes the syntax easier to understand.

Keep the [dbt Jinja function reference](https://docs.getdbt.com/reference/dbt-jinja-functions-context-variables) handy as your lookup page.