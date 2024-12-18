<!-- BEGIN_TF_DOCS -->
# Usage Example

**IMPORTANT**: To successfully complete this example, you must first deploy the module by following [module workspace example](../module\_workspace/README.md).

## Attach Run Task into HCP Terraform Workspace

Follow the steps below to attach the run task created from the module into a new HCP Terraform workspace. The new workspace will attempt to create multiple invalid IAM resources. The Run tasks integration with IAM Access Analyzer will validate it as part of post-plan stage.

* Use the provided demo workspace configuration.

  ```bash
  cd examples/demo_workspace
  ```

* Change the org name in with your own HCP Terraform org name.

  ```hcl
  terraform {

    cloud {
      # TODO: Change this to your HCP Terraform org name.
      organization = "<enter your org name here>"
      workspaces {
        ...
      }
    }
    ...
  }
  ```

* Populate the required variables, change the placeholder value below.

  ```bash
  echo 'tfc_org="<enter your org name here>"' >> tf.auto.tfvars
  echo 'aws_region="<enter the AWS region here>"' >> tf.auto.tfvars
  echo 'runtask_id="<enter the Run Task ID output from previous module deployment>"' >> tf.auto.tfvars
  echo 'demo_workspace_name="<enter the new demo workspace name here>"' >> tf.auto.tfvars
  ```

* Initialize HCP Terraform. When prompted, enter the name of the new demo workspace as you specified in the previous step.

  ```bash
  terraform init
  ```

* Configure the AWS credentials (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) in HCP Terraform, i.e. using variable sets. [Follow these instructions to learn more](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-create-variable-set).

* In order to create and configure the run tasks, you also need to have HCP Terraform token stored as Variable/Variable Sets in the workspace. Add `TFE_HOSTNAME` and `TFE_TOKEN` environment variable to the same variable set or directly on the workspace. ![TFC Configure Variable Set](../diagram/TerraformCloud-VariableSets.png?raw=true "Configure HCP Terraform Variable Set")

* Enable the flag to attach the run task to the demo workspace.

   ```bash
   echo 'flag_attach_runtask="true"' >> tf.auto.tfvars
   terraform apply
   ```

* Navigate back to HCP Terraform, locate the new demo workspace and confirm that the Run Task is attached to the demo workspace. ![TFC Run Task in Workspace](../../diagram/TerraformCloud-RunTaskWorkspace.png?raw=true "Run Task attached to the demo workspace")

## Test IAM Access Analyzer using Run Task

The following steps deploy simple IAM policy with invalid permissions. This should trigger the Run Task to send failure and stop the apply.

* Enable the flag to deploy invalid IAM policy to the demo workspace.

  ```bash
  echo 'flag_deploy_invalid_resource="true"' >> tf.auto.tfvars
  ```

* Run Terraform apply again

  ```bash
  terraform apply
  ```

* Terraform apply will fail due to several errors, use the CloudWatch link to review the errors. ![HCP TF Run Task results](../../diagram/TerraformCloud-RunTaskOutput.png?raw=true "Run Task output with IAM Access Analyzer validation")

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.72.0 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | ~>0.38.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.72.0 |
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | ~>0.38.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.sample_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.policy_with_computed_values](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.policy_with_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.policy_with_eof](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.invalid_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.invalid_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.invalid_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_organizations_policy.invalid_scp_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [tfe_workspace_run_task.aws-iam-analyzer-attach](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_run_task) | resource |
| [aws_caller_identity.current_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.invalid_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_with_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [tfe_organization.org](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/organization) | data source |
| [tfe_workspace.workspace](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The region from which this module will be executed. | `string` | n/a | yes |
| <a name="input_demo_workspace_name"></a> [demo\_workspace\_name](#input\_demo\_workspace\_name) | The workspace name | `string` | n/a | yes |
| <a name="input_runtask_id"></a> [runtask\_id](#input\_runtask\_id) | The run task id of the IAM Access Analyzer run task | `string` | n/a | yes |
| <a name="input_tfc_org"></a> [tfc\_org](#input\_tfc\_org) | Terraform Organization name | `string` | n/a | yes |
| <a name="input_flag_attach_runtask"></a> [flag\_attach\_runtask](#input\_flag\_attach\_runtask) | Switch this flag to true to attach the run task to the workspace | `bool` | `false` | no |
| <a name="input_flag_deploy_invalid_resource"></a> [flag\_deploy\_invalid\_resource](#input\_flag\_deploy\_invalid\_resource) | Switch this flag to true to deploy sample invalid IAM policy and validate it with Run Task | `bool` | `false` | no |
| <a name="input_runtask_enforcement_level"></a> [runtask\_enforcement\_level](#input\_runtask\_enforcement\_level) | The description give to the attached run task (optional) | `string` | `"mandatory"` | no |
| <a name="input_runtask_stage"></a> [runtask\_stage](#input\_runtask\_stage) | The description give to the attached run task (optional) | `string` | `"post_plan"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->