#!/usr/bin/env bash

if [[ "$DEPLOYMENT_GROUP_NAME" == *"prod"* ]]; then
    DEPLOY_ENV="prod"
fi

if [[ "$DEPLOYMENT_GROUP_NAME" == *"stg"* ]]; then
    DEPLOY_ENV="stg"
fi

if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == *"dev"* ]]; then
    DEPLOY_ENV="dev"
fi

# Get .env file from AWS SSM
cd /var/www/alvinespejo.com
echo -- /alvinespejo/$DEPLOY_ENV/env

aws --region ap-southeast-1 ssm get-parameter --with-decryption --name /alvinespejo/$DEPLOY_ENV/env --output text --query 'Parameter.Value' > .env 
echo "pull prod env"
# Set permissions
sudo chown -R ubuntu:www-data /var/www/alvinespejo.com
sudo chmod -R 775 /var/www/alvinespejo.com/storage
sudo chmod -R 775 /var/www/alvinespejo.com/bootstrap/cache
echo "Set permissions"

# Below conditional syntax from here:
# https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash
# Env var available for appspec hooks:
# https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html#reference-appspec-file-structure-environment-variable-availability

# Reload php-fpm (clear opcache) if a web server
if [[ "$DEPLOYMENT_GROUP_NAME" == *"http"* ]]; then
    service php8.0-fpm reload
    echo "Restart PHP"
fi

# Start supervisor jobs (if supervisor is used)
if [[ "$DEPLOYMENT_GROUP_NAME" == *"queue"* ]]; then
    supervisorctl start all
    echo "Restart supervisor"
fi


sudo -u ubuntu php artisan migrate --force

echo "DB migration"