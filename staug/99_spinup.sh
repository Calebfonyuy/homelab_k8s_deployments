#!/bin/bash
 
kubectl apply -f 00_namespace.yaml

kubectl apply -f 01_secrets.yaml

kubectl apply -f 02_configmap.yaml

kubectl apply -f 03_postgres.yaml

echo "Wait for Postgres services to run"
sleep 20
kubectl apply -f 04_redis.yaml

echo "Wait for Redis services to run"
sleep 20
kubectl apply -f 05_minio.yaml

echo "Wait for Minio services to run"
sleep 10
kubectl apply -f 06_api_service.yaml

echo "Wait for Auth services to run"
sleep 10
kubectl apply -f 07_projection_service.yaml

echo "Wait for Projection service to run"
sleep 10
kubectl apply -f 08_frontend_service.yaml

echo "All Services have been started"