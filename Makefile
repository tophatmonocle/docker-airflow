
.PHONY container_image
container:  aws ecr get-login --no-include-email --region us-east-1
            docker build -t "airflow" . --no-cache
            docker tag airflow:latest 008963853103.dkr.ecr.us-east-1.amazonaws.com/airflow:latest # TODO - indicate correct ECR here
            docker push 008963853103.dkr.ecr.us-east-1.amazonaws.com/airflow:latest


.PHONY: deploy
deploy: sceptre --dir sceptre launch-env dev
        zappa deploy prod || zappa update prod # TODO is zappa the correct command?
        # zappa deploy healthcheck || zappa update healthcheck - why are these different?

validate: sceptre --dir sceptre validate-template dev cluster_infrastructure
