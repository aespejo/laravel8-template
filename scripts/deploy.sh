#!/usr/bin/env bash

# Deploy web servers
aws --region ap-southeast-1 deploy create-deployment \
    --application-name cloudcasts-$1-deploy-app \
    --deployment-group-name "cloudcasts-$1-http-deploy-group" \
    --description "Deploying tag $CODEBUILD_WEBHOOK_TRIGGER" \
    --s3-location "bucket=cloudcasts-$1-artifacts,bundleType=zip,key=$CODEBUILD_RESOLVED_SOURCE_VERSION.zip"

# Deploy queues
aws --region ap-southeast-1 deploy create-deployment \
    --application-name cloudcasts-$1-deploy-app \
    --deployment-group-name "cloudcasts-$1-queue-deploy-group" \
    --description "Deploying tag $CODEBUILD_WEBHOOK_TRIGGER" \
    --s3-location "bucket=cloudcasts-$1-artifacts,bundleType=zip,key=$CODEBUILD_RESOLVED_SOURCE_VERSION.zip"