#---------
# Backend 
#---------
terraform {
  backend "azurerm" {}
}

#---------------
# Random String
#---------------
module "random_string" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-random-string.git?ref=v1.0.0"

  length  = 4
  lower   = true
  numeric = true
  special = false
  upper   = false
}

#----------------
# Resource Group
#----------------
module "resource_group" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-resource-group.git?ref=v1.0.0"

  for_each   = var.resource_group
  name       = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
  location   = var.helpers.region
  managed_by = lookup(each.value, "managed_by", null)

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#-----------------
# Virtual Network
#-----------------
module "virtual_network" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-virtual-network.git?ref=v1.0.0"

  for_each                = var.virtual_network
  name                    = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
  resource_group_name     = module.resource_group[each.value.resource_group].name
  location                = var.helpers.region
  address_space           = each.value.address_space
  bgp_community           = lookup(each.value, "bgp_community", null)
  ddos_protection_plan    = lookup(each.value, "ddos_protection_plan", {})
  encryption              = lookup(each.value, "encryption", {})
  dns_servers             = lookup(each.value, "dns_servers", [])
  edge_zone               = lookup(each.value, "edge_zone", null)
  flow_timeout_in_minutes = lookup(each.value, "flow_timeout_in_minutes", null)
  subnet                  = lookup(each.value, "subnet", {})
  subnets                 = lookup(each.value, "subnets", {})

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}


#------------------------
# User Assigned Identity
#------------------------
module "user_assigned_identity" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-user-assigned-identity.git?ref=v1.0.0"

  for_each            = var.user_assigned_identity
  name                = "${each.value.name}-${local.resource_suffix}-${module.random_string.result}"
  location            = var.helpers.region
  resource_group_name = module.resource_group[each.value.resource_group].name

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#--------------------
# Container Registry
#--------------------
module "container_registry" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-container-registry.git?ref=v1.0.0"

  for_each                      = var.container_registry
  name                          = replace("${each.value.name}-${local.resource_suffix}-${module.random_string.result}", "/[[:^alnum:]]/", "")
  resource_group_name           = module.resource_group[each.value.resource_group].name
  location                      = var.helpers.region
  sku                           = each.value.sku
  admin_enabled                 = lookup(each.value, "admin_enabled", false)
  georeplications               = lookup(each.value, "georeplications", {})
  network_rule_set              = lookup(each.value, "network_rule_set", {})
  public_network_access_enabled = lookup(each.value, "public_network_access_enabled", true)
  quarantine_policy_enabled     = lookup(each.value, "quarantine_policy_enabled", null)
  retention_policy_in_days      = lookup(each.value, "retention_policy_in_days", 7)
  trust_policy_enabled          = lookup(each.value, "trust_policy_enabled", false)
  zone_redundancy_enabled       = lookup(each.value, "zone_redundancy_enabled", false)
  export_policy_enabled         = lookup(each.value, "export_policy_enabled", true)
  encryption                    = lookup(each.value, "encryption", {})
  anonymous_pull_enabled        = lookup(each.value, "anonymous_pull_enabled", null)
  data_endpoint_enabled         = lookup(each.value, "data_endpoint_enabled", null)
  network_rule_bypass_option    = lookup(each.value, "network_rule_bypass_option", "AzureServices")

  identity = {
    type         = each.value.identity.type
    identity_ids = each.value.identity.type == "UserAssigned" || each.value.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[each.value.identity.identity].id] : null
  }

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(each.value, "resource_tags", local.resource_tags).team
      owner = lookup(each.value, "resource_tags", local.resource_tags).owner
    }
  )
}

#--------------------------
# Azure Kubernetes Cluster
#--------------------------
locals {
  default_node_pool = {
    vnet_subnet_id = module.virtual_network[var.aks.aks_vnet].subnets[var.aks.aks_subnet].id
  }
  microsoft_defender = {}
  oms_agent          = {}
}

module "aks" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-kubernetes-cluster.git?ref=v1.0.0"

  name                       = "${var.aks.name}-${local.resource_suffix}-${module.random_string.result}"
  location                   = var.helpers.region
  resource_group_name        = module.resource_group[var.aks.resource_group].name
  default_node_pool          = merge(var.aks.default_node_pool, local.default_node_pool)
  dns_prefix_private_cluster = lookup(var.aks, "dns_prefix_private_cluster", null)
  aci_connector_linux        = lookup(var.aks, "aci_connector_linux", {})
  automatic_upgrade_channel  = lookup(var.aks, "automatic_upgrade_channel", null)
  api_server_access_profile  = lookup(var.aks, "api_server_access_profile", {})
  auto_scaler_profile        = lookup(var.aks, "auto_scaler_profile", {})
  azure_active_directory_role_based_access_control = {
    admin_group_object_ids = [var.AKS-Admins_OBJECT_ID]
    azure_rbac_enabled     = false
  }
  azure_policy_enabled             = lookup(var.aks, "azure_policy_enabled", null)
  confidential_computing           = lookup(var.aks, "confidential_computing", {})
  cost_analysis_enabled            = lookup(var.aks, "cost_analysis_enabled", false)
  disk_encryption_set_id           = lookup(var.aks, "disk_encryption_set_id", null)
  edge_zone                        = lookup(var.aks, "edge_zone", null)
  http_application_routing_enabled = lookup(var.aks, "http_application_routing_enabled", null)
  http_proxy_config                = lookup(var.aks, "http_proxy_config", {})
  identity = {
    type         = var.aks.identity.type
    identity_ids = var.aks.identity.type == "UserAssigned" || var.aks.identity.type == "SystemAssigned, UserAssigned" ? [module.user_assigned_identity[var.aks.identity.identity].id] : null
  }
  image_cleaner_enabled        = lookup(var.aks, "image_cleaner_enabled", null)
  image_cleaner_interval_hours = lookup(var.aks, "image_cleaner_interval_hours", 48)
  ingress_application_gateway  = lookup(var.aks, "ingress_application_gateway", {})
  key_management_service       = lookup(var.aks, "key_management_service", {})
  key_vault_secrets_provider   = lookup(var.aks, "key_vault_secrets_provider", {})
  kubelet_identity             = lookup(var.aks, "kubelet_identity", {})
  linux_profile = {
    adminuser  = var.admin_username
    public_key = var.public_key
  }
  local_account_disabled              = lookup(var.aks, "local_account_disabled", null)
  maintenance_window                  = lookup(var.aks, "maintenance_window", {})
  maintenance_window_auto_upgrade     = lookup(var.aks, "maintenance_window_auto_upgrade", {})
  maintenance_window_node_os          = lookup(var.aks, "maintenance_window_node_os", {})
  microsoft_defender                  = merge(lookup(var.aks, "microsoft_defender", {}), local.microsoft_defender)
  monitor_metrics                     = lookup(var.aks, "monitor_metrics", {})
  network_profile                     = lookup(var.aks, "network_profile", {})
  node_os_upgrade_channel             = lookup(var.aks, "node_os_upgrade_channel", "NodeImage")
  node_resource_group                 = lookup(var.aks, "node_resource_group", null)
  oidc_issuer_enabled                 = lookup(var.aks, "oidc_issuer_enabled", null)
  oms_agent                           = merge(lookup(var.aks, "oms_agent", {}), local.oms_agent)
  open_service_mesh_enabled           = lookup(var.aks, "open_service_mesh_enabled", null)
  private_cluster_enabled             = lookup(var.aks, "private_cluster_enabled", false)
  private_dns_zone_id                 = lookup(var.aks, "private_dns_zone_id", null)
  private_cluster_public_fqdn_enabled = lookup(var.aks, "private_cluster_public_fqdn_enabled", false)
  service_mesh_profile                = lookup(var.aks, "service_mesh_profile", {})
  workload_autoscaler_profile         = lookup(var.aks, "workload_autoscaler_profile", {})
  workload_identity_enabled           = lookup(var.aks, "workload_identity_enabled", false)
  role_based_access_control_enabled   = lookup(var.aks, "role_based_access_control_enabled", true)
  run_command_enabled                 = lookup(var.aks, "run_command_enabled", true)
  service_principal                   = lookup(var.aks, "service_principal", {})
  sku_tier                            = lookup(var.aks, "sku_tier", null)
  storage_profile                     = lookup(var.aks, "storage_profile", {})
  support_plan                        = lookup(var.aks, "support_plan", "KubernetesOfficial")
  web_app_routing                     = lookup(var.aks, "web_app_routing", {})
  windows_profile = {
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  kubernetes_cluster_node_pool = var.aks.kubernetes_cluster_node_pool
  nodepool_subnet_id           = module.virtual_network[var.aks.aks_vnet].subnets[var.aks.aks_nodepool_subnet].id
  aks_extension                = lookup(var.aks, "aks_extension", {})

  tags = merge(
    local.timestamp_tag,
    local.common_tags,
    {
      team  = lookup(var.aks, "resource_tags", local.resource_tags).team
      owner = lookup(var.aks, "resource_tags", local.resource_tags).owner
    }
  )
}

#------------------
# Role Assignments
#------------------
locals {
  role_assignments = {
    role_01 = {
      scope                = local.default_node_pool.vnet_subnet_id
      role_definition_name = "Network Contributor"
      principal_id         = module.user_assigned_identity["aks"].principal_id
    },
    role_02 = {
      scope                = module.aks.kubernetes_cluster_node_pool["infrateam"].vnet_subnet_id
      role_definition_name = "Network Contributor"
      principal_id         = module.user_assigned_identity["aks"].principal_id
    },
    role_03 = {
      scope                = module.resource_group["default"].id
      role_definition_name = "Contributor"
      principal_id         = module.user_assigned_identity["aks"].principal_id
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