#Airflow Cluster

Airflow is a job scheduler that we used to run our ETL jobs.  At THM, we run Airflow on a cluster of Docker containers, which is managed by AWS Fargate.

##Contributing

Airflow jobs are found in the `/dags/` folder.  To edit or contribute a DAG, submit a PR.  It will require approval before it can be merged an deployed.  Post a message to #analytics or #data-council (?) on Slack if you can't find a reviewer.

TBA - Contribution guidelines.

##Deploy process

Note:  This is how this is *going* to work, not how it currently works (which it doesn't).

Once a PR is merged into master, a build and deploy is triggered on Jenkins.  A new container is created with the new dags/dependencies, and the stack described in `fargate-airflow-template.yml` is deployed via CloudFormation.  Basic smoketests are run, and if they fail, the cluster rolls back to its previous version.

This process takes about X minutes to complete.

##Local running

Scenario #1 - Testing DAGs

Local testing of Airflow can be rather difficult because most jobs need to access resources (DBs, S3 buckets, etc...) that are not accessible from your dev environment.  But there are still sometimes cases you might like to try this.

Scenario #2 - Testing Dockerfile changes.

There are cases when the Dockerfile might need to be updated, such as when new dependencies or plugins need to be added.   

For either/both of the above scenarios, you can run the cluster on your local as follows:

1.  Build your new dockerfile using `docker build -t "airflow" . --no-cache`
2.  Put up a cluster on your local using `docker-compose -f docker-compose-CeleryExecutor.yml up`
3.  Connect to the webserver at `localhost:8080`.  
4.  The queue can be monitored at `localhost:5555`, if necessary. 