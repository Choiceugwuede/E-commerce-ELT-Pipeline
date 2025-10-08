#!/bin/bash
cd /mnt/c/Users/CDE/ETL_PIPELINE

echo "Clearing cache"
docker-compose down -v

echo "Pulling latest image"
docker-compose pull

echo "Starting pipeline"
docker-compose up --abort-on-container-exit