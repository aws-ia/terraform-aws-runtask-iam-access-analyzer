## Notes: all variables loaded via functional test

run "runtasks_is_setup" {
  # run this first to deploy the module
  module {
    source = "./tests/setup"
  }

  assert {
    # runtask id always start with task-xxxx
    condition = substr(module.runtask_iam_access_analyzer.runtask_id, 0, 4) == "task"
    error_message = "Invalid run tasks id / failed to create run tasks"
  }

  assert {
    # runtask URL will return 400 for unauthenticated access 
    condition = data.http.runtask_url.status_code == 400
    error_message = "Runtask URL responded with HTTP status ${data.http.runtask_url.status_code}"
  } 
}

run "validate_workspace" {
  # attach run task to another test workspace
  variables {
    flag_attach_runtask = "true"
    flag_deploy_invalid_resource = "false"
    runtask_enforcement_level = "mandatory"
    runtask_stage = "post_plan"
    runtask_id = run.runtasks_is_setup.runtask_id
  }

  module {
    source = "./tests/validate"
  }

  assert {
    # Workspace runtask id always start with wstask-xxxx
    condition = substr(tfe_workspace_run_task.aws-iam-analyzer-attach[0].id, 0, 6) == "wstask"
    error_message = "Invalid workspace run tasks id / failed to attach run tasks to workspace"
  }
}

# Warning : unable to confirm if this test run effectively, see https://discuss.hashicorp.com/t/terraform-test-with-tfc-workspaces/63351
run "validate_access_analyzer" {
  # run apply on the test workspace to validate results
  command = plan 
  
  variables {
    flag_attach_runtask = "true"
    flag_deploy_invalid_resource = "true"
    runtask_enforcement_level = "mandatory"
    runtask_stage = "post_plan"
    runtask_id = run.runtasks_is_setup.runtask_id
  }

  module {
    source = "./tests/validate"
  }

}
