#!/bin/bash
cd /mnt/c/Users/Bluechip/CDE/ETL_PIPELINE

echo "Pulling latest image"
docker-compose pull

echo "Starting pipeline"
docker-compose up --abort-on-container-exit

echo "Pipeline finished"
docker-compose down