#---------
# Backend 
#---------
terraform {
  backend "azurerm" {}
}

#-------------
# Hub Backend
#-------------
data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = data.azurerm_storage_account.storage_account.resource_group_name
    storage_account_name = data.azurerm_storage_account.storage_account.name
    container_name       = "hub"
    key                  = "dev/hub.dev.tfstate"
    subscription_id      = var.subscription_id
    access_key           = data.azurerm_storage_account.storage_account.primary_access_key
  }
}

#---------------------
# Kubernetes Provider
#---------------------
provider "kubernetes" {
  config_path = "~/.kube/config"
}

#---------------
# Helm Provider
#---------------
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

#------------------
# Kubectl Provider
#------------------
provider "kubectl" {
  config_path = "~/.kube/config"
}

#------------------
# Role Assignments
#------------------
locals {
  role_assignments = {
    AcrPull = {
      scope                = data.terraform_remote_state.hub.outputs.container_registry["default"].id
      role_definition_name = "AcrPull"
      principal_id         = data.azurerm_user_assigned_identity.aks-agentpool.principal_id
    },
  }
}

module "role_assignments" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-role-assignment.git?ref=v1.0.0"

  for_each             = merge(try(var.role_assignments, null), local.role_assignments)
  scope                = each.value.scope
  role_definition_id   = lookup(each.value, "role_definition_id", null)
  role_definition_name = lookup(each.value, "role_definition_name", null)
  principal_id         = each.value.principal_id
  description          = lookup(each.value, "description", null)
}

#----------------------
# Kubernetes Namespace
#----------------------
module "kubernetes_namespace" {
  source = "git::https://github.com/QuestOpsHub/terraform-kubernetes-namespace.git?ref=v1.0.0"

  for_each    = var.kubernetes_namespace
  annotations = lookup(each.value, "annotations", null)
  labels      = lookup(each.value, "labels", null)
  name        = lookup(each.value, "name", null)
}

#--------------
# cert-manager
#--------------
module "cert_manager" {
  depends_on = [module.role_assignments, module.kubernetes_namespace]
  source     = "git::https://github.com/QuestOpsHub/terraform-helm-release.git?ref=v1.0.0"

  name             = "cert-manager"
  chart            = "cert-manager"
  chart_version    = "v1.16.1"
  create_namespace = false
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  replace          = false

  set = {
    "crds.enabled" = "true"

    # Toleration for `app=infrateam:NoSchedule`
    "tolerations[0].key"      = "app"
    "tolerations[0].operator" = "Equal"
    "tolerations[0].value"    = "infrateam"
    "tolerations[0].effect"   = "NoSchedule"

    # Toleration for `CriticalAddonsOnly=true:NoSchedule`
    "tolerations[1].key"      = "CriticalAddonsOnly"
    "tolerations[1].operator" = "Exists"
    "tolerations[1].effect"   = "NoSchedule"

    # Ensure tolerations are applied to all components
    "cainjector.tolerations[0].key"      = "app"
    "cainjector.tolerations[0].operator" = "Equal"
    "cainjector.tolerations[0].value"    = "infrateam"
    "cainjector.tolerations[0].effect"   = "NoSchedule"

    "cainjector.tolerations[1].key"      = "CriticalAddonsOnly"
    "cainjector.tolerations[1].operator" = "Exists"
    "cainjector.tolerations[1].effect"   = "NoSchedule"

    "webhook.tolerations[0].key"      = "app"
    "webhook.tolerations[0].operator" = "Equal"
    "webhook.tolerations[0].value"    = "infrateam"
    "webhook.tolerations[0].effect"   = "NoSchedule"

    "webhook.tolerations[1].key"      = "CriticalAddonsOnly"
    "webhook.tolerations[1].operator" = "Exists"
    "webhook.tolerations[1].effect"   = "NoSchedule"

    # Disable the startup API check
    "startupapicheck.enabled" = "false"
  }
}

#---------------------------
# actions-runner-controller
#---------------------------
module "github_runners" {
  depends_on = [module.cert_manager]
  source     = "git::https://github.com/QuestOpsHub/terraform-helm-release.git?ref=v1.0.0"

  name             = "github-runners"
  chart            = "actions-runner-controller"
  chart_version    = "0.23.7"
  create_namespace = false
  namespace        = "github-runners"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller/"
  replace          = false

  set = {
    "authSecret.create"                   = "true"
    "authSecret.github_token"             = var.QUESTOPSHUB_PAT_TOKEN
    "image.actionsRunnerRepositoryAndTag" = "${var.ACR_NAME}.azurecr.io/infrateam/selfhosted-privaterunner:${var.github_runners_image_version}"

    # Toleration for `app=infrateam:NoSchedule`
    "tolerations[0].key"      = "app"
    "tolerations[0].operator" = "Equal"
    "tolerations[0].value"    = "infrateam"
    "tolerations[0].effect"   = "NoSchedule"

    # Toleration for `CriticalAddonsOnly=true:NoSchedule`
    "tolerations[1].key"      = "CriticalAddonsOnly"
    "tolerations[1].operator" = "Exists"
    "tolerations[1].effect"   = "NoSchedule"
  }
}

#----------------
# GitHub Runners
#----------------
resource "kubectl_manifest" "github_runners" {
  depends_on = [module.github_runners]
  yaml_body  = file("../../files/githubRunners/${var.helpers.environment}-github-runners.yaml")
}