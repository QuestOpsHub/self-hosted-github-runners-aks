#--------------------
# Required Providers
#--------------------
variable "subscription_id" {}

variable "client_id" {}

variable "client_secret" {}

variable "tenant_id" {}

#--------
# Locals
#--------
variable "helpers" {}

#------------------
# Role Assignments
#------------------
variable "role_assignments" {}

#----------------------
# Kubernetes Namespace
#----------------------
variable "kubernetes_namespace" {}

#---------------------------
# actions-runner-controller
#---------------------------
variable "QUESTOPSHUB_PAT_TOKEN" {}

variable "ACR_NAME" {}

variable "github_runners_image_version" {}