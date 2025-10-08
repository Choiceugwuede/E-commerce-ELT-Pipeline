FROM python:3.10-slim

WORKDIR /dbt

RUN pip install dbt-core dbt-postgres

COPY . .

CMD ["dbt", "run"]
