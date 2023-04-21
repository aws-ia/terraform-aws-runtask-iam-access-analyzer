provider "aws" { # for Cloudfront WAF only - must be in us-east-1
  region = "us-east-1"
  alias  = "cloudfront_waf"
}