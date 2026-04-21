# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# 1. IDENTITY & AUTH
identity_token "gcp" {
  audience = ["hcp.workload.identity"]
}

# 2. AUTO-APPROVAL POLICIES
deployment_auto_approve "safe_changes" {
  check {
    condition = (context.plan.changes.add > 0 &&
                 context.plan.changes.change == 0 &&
                 context.plan.changes.remove == 0)
    reason = "Plan adds new resources, no changes or resources removed"
  }
}

# 3. DEPLOYMENT GROUPS
deployment_group "dev" {
  auto_approve_checks = [deployment_auto_approve.safe_changes]
}

deployment_group "prod" {
  # The prod group has no rules, so it will always require manual approval.
  auto_approve_checks = []
}

# 4. DEPLOYMENTS
deployment "development" {
  group = deployment_group.dev
  destroy = true
  inputs = {
    identity_token        = identity_token.gcp.jwt
    audience              = "//iam.googleapis.com/projects/546669278926/locations/global/workloadIdentityPools/wi-pool-gcp-stacks-example/providers/wi-provider-gcp-stacks-example"
    project_id            = "hc-0915bcaa539f4a06887cc457893"
    service_account_email = "gcp-stacks-example@hc-0915bcaa539f4a06887cc457893.iam.gserviceaccount.com"
    region                = "us-central1" # <--- Dev in Iowa
  }
}

deployment "production" {
  group = deployment_group.prod
  
  inputs = {
    identity_token        = identity_token.gcp.jwt
    audience              = "//iam.googleapis.com/projects/546669278926/locations/global/workloadIdentityPools/wi-pool-gcp-stacks-example/providers/wi-provider-gcp-stacks-example"
    project_id            = "hc-0915bcaa539f4a06887cc457893"
    service_account_email = "gcp-stacks-example@hc-0915bcaa539f4a06887cc457893.iam.gserviceaccount.com"
    region                = "us-east1"    # <--- Prod in South Carolina
  }
}