package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesBasic(t *testing.T) {

	awsRegion := "us-east-1"
	ssmTfcOrg := aws.GetParameter(t, awsRegion, "/abp/tfc/functional/tfc_org")
	ssmWorkspacePrefix := aws.GetParameter(t, awsRegion, "/abp/tfc/functional/workspace_prefix")

	terraformOptions := &terraform.Options{
		Lock:         true, // Required for TFC with local execution
		TerraformDir: "../examples/module_workspace",
		Vars: map[string]interface{}{
			"tfc_org":          ssmTfcOrg,
			"workspace_prefix": ssmWorkspacePrefix,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
