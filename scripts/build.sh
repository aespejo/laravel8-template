#!/usr/bin/env bash

# Production assets/dependencies
npm install
npm run production
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev 

# Create our build artifact
git archive -o builds/cloudcasts.zip --worktree-attributes HEAD
zip -qur builds/cloudcasts.zip vendor
zip -qur builds/cloudcasts.zip public
zip -qur builds/cloudcasts.zip .env # Grab our testing .env file for now

# Upload artifact to s3
# variable $1 is the command argument that was added when calling this file
aws s3 cp builds/cloudcasts.zip s3://cloudcasts-artifacts-codebuild/$CODEBUILD_RESOLVED_SOURCE_VERSION.zip

# Change rights to the build.sh file to avoid permission denied error on build
# git update-index --add --chmod=+x build.sh
# git commit -m 'Make build.sh executable'
# git push
# OR
# before_install:
#   - chmod +x build.sh

# Command to save .env file to AWS SSM 

# Linux CLI
# aws --profile aespejo --region ap-southeast-1 ssm put-parameter \
#     --name /cloudcasts/staging/env \
#     --type SecureString \
#     --value file://.env

# Windows powershell cli
# aws --profile aespejo --region ap-southeast-1 ssm put-parameter --name /cloudcasts/staging/env --type SecureString --value file://.env

# [program:cloudcasts]
# process_name=%(program_name)s_%(process_num)02d
# command=php /home/cloudcasts/cloudcasts.io/artisan queue:listen --sleep=3 --tries=3
# autostart=true
# autorestart=true
# user=cloudcasts
# numprocs=2
# redirect_stderr=true
# stdout_logfile=/var/log/cloudcasts/queue.log
