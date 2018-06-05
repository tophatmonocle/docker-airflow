#!/usr/bin/env bash

# This file makes and deploys a container to the AWS container repository

aws ecr get-login --no-include-email --region us-east-1

docker build -t "airflow" . --no-cache

docker tag airflow:latest 008963853103.dkr.ecr.us-east-1.amazonaws.com/airflow:latest

docker push 008963853103.dkr.ecr.us-east-1.amazonaws.com/airflow:latest

