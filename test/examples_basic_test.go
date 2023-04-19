package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesBasic(t *testing.T) {

	terraformOptions := &terraform.Options{
		Lock:         true, // Required for TFC with local execution
		TerraformDir: "../examples/module_workspace",
		Vars: map[string]interface{}{
			"tfc_org":          "wellsiau-org",
			"workspace_prefix": "ia2",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
