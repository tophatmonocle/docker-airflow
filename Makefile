#!/usr/bin/env bash

IMAGE_TAG?=$(firstword $(shell git ls-tree HEAD ./dags/* packer playbooks Makefile | shasum))
AWS_ECR_PROD_REGISTRY?=306501597120.dkr.ecr.us-east-1.amazonaws.com
AWS_ECR_DEV_REGISTRY?=008963853103.dkr.ecr.us-east-1.amazonaws.com

.PHONY: delete
delete:
	sceptre --var "google_auth_client=$(shell aws ssm --with-decryption get-parameters --name "/airflow/dev/GOOGLE_AUTH_CLIENT_ID" | jq -r '.Parameters[0].Value')" --var "google_auth_secret=$(shell aws ssm get-parameters --with-decryption --names "/airflow/dev/GOOGLE_AUTH_CLIENT_SECRET" | jq -r '.Parameters[0].Value')" --dir sceptre delete-env $(environment)

.PHONY: deploy
deploy:
	aws ecr get-login --no-include-email --region us-east-1 # do I need this?
	sceptre --dir sceptre launch-stack $(environment) airflow-container-repo
	docker build -t "airflow" .
    #TODO - distinguish between dev and prod registries ...
	docker tag airflow:latest $(AWS_ECR_DEV_REGISTRY)/airflow:$(IMAGE_TAG)
	docker push $(AWS_ECR_DEV_REGISTRY)/airflow:$(IMAGE_TAG)
	sceptre --var "image_tag=$(IMAGE_TAG)" --var "google_auth_client=$(shell aws ssm --with-decryption get-parameters --name "/airflow/$(environment)/GOOGLE_AUTH_CLIENT_ID" | jq -r '.Parameters[0].Value')" --var "google_auth_secret=$(shell aws ssm get-parameters --with-decryption --names "/airflow/$(environment)/GOOGLE_AUTH_CLIENT_SECRET" | jq -r '.Parameters[0].Value')" --dir sceptre launch-env $(environment)

.PHONY: validate
validate:
	sceptre --dir sceptre validate-template $(environment) airflow-alarms
	sceptre --dir sceptre --var "google_auth_client=fake_client" --var "google_auth_secret=fake_secret" validate-template $(environment) airflow-cluster
	sceptre --dir sceptre validate-template $(environment) airflow-metadata

