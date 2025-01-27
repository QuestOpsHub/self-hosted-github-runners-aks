#--------
# Locals
#--------
helpers = {
  project          = "questopshub"
  project_short    = "qoh"
  environment      = "dev"
  region           = "centralus"
  region_short     = "cus"
  deployment       = "hub-post-process"
  deployment_short = "hpp"
  source           = "terraform"
  cost_center      = "6001"
  reason           = "JIRA-12345"
  created_by       = "veera-bhadra"
  team             = "infrateam"
  owner            = "veera-bhadra"
}

#------------------
# Role Assignments
#------------------
role_assignments = {}

#----------------------
# Kubernetes Namespace
#----------------------
kubernetes_namespace = {
  "cert-manager" = {
    name = "cert-manager"
  },
  "github-runners" = {
    name = "github-runners"
  },
}

#---------------------------
# actions-runner-controller
#---------------------------
github_runners_image_version = "v1.0.0"