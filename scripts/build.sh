#!/usr/bin/env bash

DO_BUILD="no"

if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == "branch/main" ]]; then
    DO_BUILD="yes"
fi

if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == "branch/staging" ]]; then
    DO_BUILD="yes"
fi

if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == "branch/development" ]]; then
    DO_BUILD="yes"
fi

if [[ "$CODEBUILD_WEBHOOK_TRIGGER" == "tag/"* ]]; then
    DO_BUILD="yes"
fi

if [[ "$DO_BUILD" == "yes" ]]; then
    # Production assets/dependencies
    npm install
    npm run production
    composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev 

    # Create our build artifact
    git archive -o builds/alvinespejo.zip --worktree-attributes HEAD
    zip -qur builds/alvinespejo.zip vendor
    zip -qur builds/alvinespejo.zip node_modules
    zip -qur builds/alvinespejo.zip public
    zip -qur builds/alvinespejo.zip .env # Grab our testing .env file for now

    # Upload artifact to s3
    # variable $1 is the command argument that was added when calling this file
    aws s3 cp builds/alvinespejo.zip s3://alvinespejo-artifacts-codebuild/$CODEBUILD_RESOLVED_SOURCE_VERSION.zip
fi

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
#     --name /alvinespejo/staging/env \
#     --type SecureString \
#     --value file://.env

# Windows powershell cli
# aws --profile aespejo --region ap-southeast-1 ssm put-parameter --name /alvinespejo/staging/env --type SecureString --value file://.env
