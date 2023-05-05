<!-- BEGIN_TF_DOCS -->
# Usage Example

First step is to deploy the module into dedicated Terraform Cloud workspace. The output `runtask_id` is used on other Terraform Cloud workspace to configure the runtask.

* Build and package the Lambda files using the makefile. Run this command from the root directory of this repository.
  ```bash
  make all
  ```

* Use the provided module example to deploy the solution.

  ```bash
  cd examples/module_workspace
  ```

* Change the org name to your TFC org.

  ```
  terraform {

    cloud {
      # TODO: Change this to your Terraform Cloud org name.
      organization = "<enter your org name here>"
      workspaces {
        ...
      }
    }
    ...
  }   
  ```

* Initialize Terraform Cloud. When prompted, enter a new workspace name, i.e. `aws-ia2-infra`
  ```bash
  terraform init
  ```

* Configure the new workspace (i.e `aws-ia2-infra`) in Terraform Cloud to use `local` execution mode. Skip this if you publish the module into Terraform registry.

* Configure the AWS credentials (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) by using environment variables.

* In order to create and configure the run tasks, you also need to have Terraform Cloud token stored as Environment Variables. Add `TFE_HOSTNAME` and `TFE_TOKEN` environment variable.

* Run Terraform apply
  ```bash
  terraform apply
  ```

* Use the output value `runtask_id` when deploying the demo workspace. See example of [demo workspace here](../demo\_workspace/README.md)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~>2.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.73.0, < 5.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.4.0 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | ~>0.38.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.73.0, < 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_runtask_iam_access_analyzer"></a> [runtask\_iam\_access\_analyzer](#module\_runtask\_iam\_access\_analyzer) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tfc_org"></a> [tfc\_org](#input\_tfc\_org) | n/a | `string` | n/a | yes |
| <a name="input_workspace_prefix"></a> [workspace\_prefix](#input\_workspace\_prefix) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_runtask_id"></a> [runtask\_id](#output\_runtask\_id) | n/a |
<!-- END_TF_DOCS -->