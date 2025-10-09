# E-Commerce ELT Pipeline

## Project Overview

This project implements a fully managed ELT pipeline for an e-commerce store. It runs end-to-end, performing extraction, loading, transformation, and visualization.

The pipeline performs the following steps:

1. **Extract -** A Python script that reads data from the business flat file (CSV).
2. **Load -** The Script loads the data into a staging PostgreSQL table.
3. **Transform -** DBT models transforms the data to produce a gold layer table for analysis.
4. **Dashboard-** The final table is connected to a BI dashbaord reflecting the latest figures for informed decision making.

The pipeline runs inside Docker Containers, making it portable and reproducible across environments.

It is also scheduled to run automatically every day at **12:00am** using a cron job on Ubuntu.

## Architecture

<img width="895" height="453" alt="Untitled Diagram drawio" src="https://github.com/user-attachments/assets/4c9f1f89-0062-4885-bef7-b58e4d62cf3f" />

### Components
1. Docker Compose (orchestration)
   - Single docker-compose.yml defines services: postgres,pgadmin,extractor, and dbt.
   - Creates an isolated Docker network so containers address each other by their service name.
   - Host-to-container port mappings: 5333:5432 (Postgres to host), 8091:80 (pgAdmin to host).

2. Postgres container
   - Offcial Postgres image.
   - Persistent storage via mounted volume.
   - Healthcheck uses pg_isready so other services(containers) wait for readiness.

3. pgAdmin container
   - Optional: UI to explore postgres database

4. Extractor Container
   - Custom image built.
   - Depends on postgres
   - Runs Python script which:
     - Reads CSV from source
     - Connects to database
     - Does a full load
   - Volume mounts for persistent logs.

5. DBT container
   - Custom image built.
   - Depends on extractor with condition: service_completed_succesfully so dbt runs only after extractor exits 0(completes).
   - Contains Models that does transformation on loaded data.
   - Produces final summary table

#### Data Flow:
``` 
CSV → Extractor (Python) → Postgres (staging table) → dbt (transforms) → final table → Dashboard
```

## Dashboard

<img width="885" height="495" alt="image" src="https://github.com/user-attachments/assets/74a83a91-9bc0-4596-ab9a-38fcdb7b292b" />

## Requirements:
- [Docker desktop](https://docs.docker.com/desktop/setup/install/windows-install/) 
  - For Windows: Set up WS integration (for Ubuntu Cron Jobs)
- [Python 3.10+](https://www.python.org/downloads/)
- For Windows: [Ubuntu](https://ubuntu.com/download/desktop) (for scheduling with for cron)

## Setup Instructions
### 1. Clone the respository

``` bash
bash

git clone https://github.com/Choiceugwuede/E-commerce-ELT-Pipeline.git
cd etl_pipeline
```

### 2. Set Environment Variables
Create a .env file inside Extract_Load/ with the following:

``` env
PG_HOST=postgres
PG_PORT=5432
PG_USER=postgres
PG_PASSWORD=postgres
PG_DB=staging
CSV_URL="https://drive.google.com/uc?export=download&id=1Q09n-VfvExVl0JGaRLPVB-kmxqM2dEV6"
LOG_PATH=/logs/extractor.log
```

### 3. Pull latest Docker Images 
**In your bash terminal, run:**
``` bash
docker-compose pull
```

### 4. Build and Start Containers 
``` bash
docker-compose up
docker-compose up -d # Run in background
```

This will:
- Start Postgres on port 5432
- Start pgAdmin on port 8091 (for UI)
- Run the Extractor to extract and load into database
- Run DBT to transform the data into the final table.

### 5. Scheduling with Cron
A bash script is created to run the pipeline automatically every day at 12:00 am.
- Open the crontab editor:
  ``` bash
  crontab -e
  ```
- Add the following line( replace /mnt/c/Users/CDE/ETL_PIPELINE) with your path):
  ```
  0 0 * * * /bin/bash /mnt/c/Users/CDE/ETL_PIPELINE/ETL_PIPELINE/run_pipeline.sh >> /mnt/c/Users/CDE/ETL_PIPELINE/ETL_PIPELINE/pipeline.log 2>&1
  ```

**Note:** For Windows Os, Cron jobs must run in Ubuntu. 
- Download Ubuntu
- Activate the environment in your terminal
  ``` bash
  wsl.exe -d Ubuntu  -- launch ubuntu
  ```
Ensure WSL integration is enbaled in Docker Desktop:

Docker Desktop - Settings - Resources 

<img width="593" height="244" alt="image" src="https://github.com/user-attachments/assets/ed6c26cb-2bf2-4761-923c-e4fe7250dcbe" />

### 6. Docker Hub Images
All custom images (Extractor, dbt) are tagged and pushed to Docker Hub.
- Repository: choiceugwuede
- Pull the latest images as specified above.

### 7. Logging
- Extractor logs: Available [here](https://github.com/Choiceugwuede/E-commerce-ELT-Pipeline/blob/main/logs/extractor.log) and captured in the container.
  <img width="777" height="242" alt="image" src="https://github.com/user-attachments/assets/2ad60d34-a052-462b-bc62-50e4d5f188cc" />
- dbt logs: Available [here](https://github.com/Choiceugwuede/E-commerce-ELT-Pipeline/blob/main/Dbt_workload/logs/dbt.log) and captured in the container.
- Automated Pipeline logs : From the run_pipeline.sh script)
  
We added try/except blocks in Python with exc_info=True for detailed task loggings and traceble error.

### 8. Dashboard
Once transformations are complete, the result can be visulaized in any BI tool.

#### Metrics:
- Total Sales
- Number of Customers
- Number of Invoices
- Country
- Invoice Date.

## Troubleshooting checklist
- Permission denied talking to Docker from WSL: enable Docker Desktop WSL integration.
- Port already in use: change host mapping
- Extractor fails on TRUNCATE: use try/except to manage the process.
- dbt running before extractor is completed: remove old volume every new run.




