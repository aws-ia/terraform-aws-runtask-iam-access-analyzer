#!/bin/bash

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Functional Tests"

#********** Terraform Test execution **********
cd ${PROJECT_PATH}
echo "Running Terraform test"
terraform test
if [ $? -eq 0 ] 
then
    echo "Terraform Test Successfull"
else
    echo "Terraform Test Failed"
    exit 1
fi

echo "End of Functional Tests"

# Test