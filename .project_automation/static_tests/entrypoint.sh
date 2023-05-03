#!/bin/bash -ex

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Static Tests"

echo "Starting Static Tests"

cd ${PROJECT_PATH}
terraform init
terraform validate

tflint --init
tflint

tfsec .

mdl .header.md

terraform-docs --lockfile=false ./

echo "End of Static Tests"