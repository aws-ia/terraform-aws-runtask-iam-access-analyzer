#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Functional Tests"

cd ${PROJECT_PATH}

#********** TFC Env Vars *************
export AWS_DEFAULT_REGION=us-east-1
export TFE_TOKEN=`aws secretsmanager get-secret-value --secret-id abp/tfc/token | jq -r ".SecretString"`
export TF_TOKEN_app_terraform_io=`aws secretsmanager get-secret-value --secret-id abp/tfc/token | jq -r ".SecretString"`

#********** MAKEFILE *************
echo "Build the lambda function packages"
make all

#********** Get tfvars from SSM *************
echo "Get *.tfvars from SSM parameter"
aws ssm get-parameter \
  --name "/abp/tfc/functional/tfc_org/terraform_test.tfvars" \
  --with-decryption \
  --query "Parameter.Value" \
  --output "text" \
  --region "us-east-1" >> ./tests/terraform.auto.tfvars

#********** Terraform Test execution **********
echo "Running Terraform test"
cd ${PROJECT_PATH}/tests/setup
terraform init
cd ${PROJECT_PATH}/tests/validate
terraform init
cd ${PROJECT_PATH}
terraform init
if TF_TEST="$(terraform test)"
then
    echo "$TF_TEST"
    echo "Terraform Test Successfull"
else
    echo "$TF_TEST"
    echo "Terraform Test Failed"
fi

#********** CLEANUP *************
echo "Cleaning up all temp files and artifacts"
cd ${PROJECT_PATH}
make clean

echo "End of Functional Tests"