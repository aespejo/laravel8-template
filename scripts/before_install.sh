#!/usr/bin/env bash

# Stop supervisor jobs (if supervisor is used)
if [[ "$DEPLOYMENT_GROUP_NAME" == *"queue"* ]]; then
    supervisorctl stop all
fi

sudo rm -rf /var/www/cloudcasts.io