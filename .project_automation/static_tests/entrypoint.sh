#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype
git config --global --add safe.directory ${PROJECT_PATH}

echo "Starting Static Tests"

cd ${PROJECT_PATH}
terraform init
terraform validate

#********** tflint ********************
echo 'Starting tflint'
tflint --init
MYLINT=$(tflint --force)
if [ -z "$MYLINT" ]
then
    echo "Success - tflint found no linting issues!"
else
    echo "Failure - tflint found linting issues!" 
    echo "$MYLINT"
    exit 1
fi
#********** tfsec *********************
# tfsec will report to the console with success or Failure
# therefore there is no need to provide such conditional stetements
echo 'Starting tfsec'
tfsec .
#********** Markdown Lint **************
echo 'Starting markdown lint'
MYMDL=$(mdl .header.md || true)
if [ -z "$MYMDL" ]
then
    echo "Success - markdown lint found no linting issues!"
else
    echo "Failure - markdown lint found linting issues!" 
    echo "$MYMDL"
    exit 1
fi
#********** Terraform Docs *************
echo 'Starting terraform-docs'
TDOCS="$(terraform-docs --lockfile=false ./)"
git add -N README.md
GDIFF="$(git diff --compact-summary)"
if [ -z "$GDIFF" ]
then
    echo "Success - Terraform Docs creation verified!"
else
    echo "Failure - Terraform Docs creation failed, ensure you have precommit installed and running before submitting the Pull Request"
    exit 1
fi
#***************************************
echo "End of Static Tests"