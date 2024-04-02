## NOTE: please do not remove / modify this file
# create additional *.tftest.hcl for your own unit / integration tests

run "plan" {
# call root module to run terraform plan
# use tests/*.auto.tfvars to add non-default variables
  command = plan 
}

run "apply" {
# call the examples/basic to test the examples
# use tests/*.auto.tfvars to add non-default variables
  command = plan 
  module {
    source = "../examples/basic"
  }
}