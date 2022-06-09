#!/bin/bash 
set -o pipefail

BACKEND_PATH=$1

mkdir configs/
cat << EOF > configs/generated_config.yml
version: 2.1

orbs:
  cloudrun: circleci/gcp-cloud-run@1.0.2

executors:
  my-executor:
    docker:
      - image: 'cimg/base:stable'

jobs:
  build_and_deploy:
    executor: my-executor
    steps:
      - checkout
      - cloudrun/init
      - cloudrun/build:
          tag: 'gcr.io/${GOOGLE_PROJECT_ID}/${GOOGLE_SERVICE_NAME}'
          source: "$BACKEND_PATH"

      - run:
          name: Run collectstatic and migrations
          command: |
            gcloud builds submit --config "$BACKEND_PATH.cloudbuild/migrate_collectstatic.yaml" \
            --substitutions _INSTANCE_NAME=${GOOGLE_PROJECT_ID},_REGION=${GOOGLE_REGION},_SERVICE_NAME=${GOOGLE_PROJECT_ID}
      
      - run:
          name: Deploy to CloudRun
          command: |
            gcloud run deploy ${GOOGLE_PROJECT_ID} --platform managed --region ${GOOGLE_REGION} \
            --image gcr.io/${GOOGLE_PROJECT_ID}/${GOOGLE_SERVICE_NAME} \
            --add-cloudsql-instances ${GOOGLE_PROJECT_ID}:${GOOGLE_REGION}:${GOOGLE_PROJECT_ID} \
            --allow-unauthenticated
            echo "Service Deployed"
            GET_GCP_DEPLOY_ENDPOINT=\$(gcloud beta run services describe ${GOOGLE_SERVICE_NAME} --platform managed --region ${GOOGLE_REGION} --format="value(status.address.url)")
            echo "export GCP_DEPLOY_ENDPOINT=\$GET_GCP_DEPLOY_ENDPOINT" >> \$BASH_ENV
            source \$BASH_ENV
            echo \$GCP_DEPLOY_ENDPOINT
      
      - run:
          name: Webhook Success
          command: bash "$BACKEND_PATH.circleci/webhook_callback.sh" "success"
          when: on_success

      - run:
          name: Webhook Failed
          command: bash "$BACKEND_PATH.circleci/webhook_callback.sh" "failure"
          when: on_fail
  dns_mapping:
    executor: my-executor
    steps:
      - cloudrun/init
      - run:
          name: Check DNS Mapping
          command: |
            gcloud beta run domain-mappings describe --region ${GOOGLE_REGION} --domain ${GOOGLE_PROJECT_ID}-gcp.botics.co --format="json" | jq -r '.spec.routeName' |grep ${GOOGLE_PROJECT_ID}
          
      - run:
          name: Enable DNS Mapping
          command: |
            gcloud beta run domain-mappings create --region=${GOOGLE_REGION} --service=${GOOGLE_PROJECT_ID} --domain=${GOOGLE_PROJECT_ID}-gcp.botics.co --project=${GOOGLE_PROJECT_ID}
          when: on_fail


workflows:
  build_and_deploy_to_managed_workflow:
    jobs:
      - build_and_deploy
      - dns_mapping:
          requires:
            - build_and_deploy
EOF