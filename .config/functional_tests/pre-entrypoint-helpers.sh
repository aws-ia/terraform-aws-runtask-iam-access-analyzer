#********** Project Path *************
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype
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

#********** Terraform Test initialize *************
echo "Initialize module for Terraform test"
cd ${PROJECT_PATH}/tests/setup
terraform init
cd ${PROJECT_PATH}/tests/validate
terraform init
cd ${PROJECT_PATH}
terraform init