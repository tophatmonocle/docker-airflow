#!/usr/bin/env bash

.PHONY: container
container:
	aws ecr get-login --no-include-email --region us-east-1
	docker build -t "airflow" .
	docker tag airflow:latest 008963853103.dkr.ecr.us-east-1.amazonaws.com/airflow:latest # TODO - indicate correct ECR here
	docker push 008963853103.dkr.ecr.us-east-1.amazonaws.com/airflow:latest

.PHONY: delete_dev
delete_dev:
	sceptre --var "google_auth_client=$(shell aws ssm --with-decryption get-parameters --name "/airflow/dev/GOOGLE_AUTH_CLIENT_ID" | jq -r '.Parameters[0].Value')" --var "google_auth_secret=$(shell aws ssm get-parameters --with-decryption --names "/airflow/dev/GOOGLE_AUTH_CLIENT_SECRET" | jq -r '.Parameters[0].Value')" --dir sceptre delete-env dev

.PHONY: deploy_dev
deploy_dev:
	sceptre --var "google_auth_client=$(shell aws ssm --with-decryption get-parameters --name "/airflow/dev/GOOGLE_AUTH_CLIENT_ID" | jq -r '.Parameters[0].Value')" --var "google_auth_secret=$(shell aws ssm get-parameters --with-decryption --names "/airflow/dev/GOOGLE_AUTH_CLIENT_SECRET" | jq -r '.Parameters[0].Value')" --dir sceptre launch-env dev

.PHONY: deploy_prod
deploy_prod:
	sceptre --dir sceptre launch-env prod $(shell aws ssm get-parameters --with-decryption --names "/airflow/dev/GOOGLE_AUTH_CLIENT_ID") $(shell aws ssm get-parameters --with-decryption --names "/airflow/dev/GOOGLE_AUTH_CLIENT_SECRET")

.PHONY: validate
validate:
	sceptre --dir sceptre validate-template dev airflow-alarms
	sceptre --dir sceptre --var "google_auth_client=fake_client" --var "google_auth_secret=fake_secret" validate-template dev airflow-cluster
	sceptre --dir sceptre validate-template dev airflow-metadata

.PHONY: deploy_cluster
deploy_cluster:
	sceptre --dir sceptre launch-stack cluster-infrastructure
