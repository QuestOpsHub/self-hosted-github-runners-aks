#--------
# Locals
#--------
helpers = {
  project          = "questopshub"
  project_short    = "qoh"
  environment      = "prod"
  region           = "centralus"
  region_short     = "cus"
  deployment       = "hub"
  deployment_short = "hub"
  source           = "terraform"
  cost_center      = "6001"
  reason           = "JIRA-12345"
  created_by       = "veera-bhadra"
  team             = "infrateam"
  owner            = "veera-bhadra"
}

#----------------
# Resource Group
#----------------
resource_group = {
  "default" = {
    name = "rg"
  },
}

#-----------------
# Virtual Network
#-----------------
virtual_network = {
  "default" = {
    name           = "vnet"
    resource_group = "default"
    address_space  = ["14.0.0.0/16", "15.0.0.0/16", "16.0.0.0/16"]
    subnets = {
      default = {
        name             = "default"
        address_prefixes = ["14.0.0.0/20"]
      },
      aks = {
        name             = "aks"
        address_prefixes = ["15.0.0.0/20"]
      },
      aks-nodepool = {
        name             = "aks-nodepool"
        address_prefixes = ["16.0.0.0/20"]
      },
    }
  },
}

#------------------------
# User Assigned Identity
#------------------------
user_assigned_identity = {
  "acr" = {
    name           = "id"
    resource_group = "default"
  },
  "aks" = {
    name           = "id"
    resource_group = "default"
  }
}

#--------------------
# Container Registry
#--------------------
container_registry = {
  "default" = {
    name           = "acr"
    resource_group = "default"
    sku            = "Standard"
    identity = {
      type     = "UserAssigned"
      identity = "acr"
    }
  }
}

#--------------------------
# Azure Kubernetes Cluster
#--------------------------
aks = {
  name                = "aks"
  resource_group      = "default"
  aks_vnet            = "default"
  aks_subnet          = "aks"
  aks_nodepool_subnet = "aks-nodepool"
  default_node_pool = {
    name                 = "system"
    vm_size              = "Standard_DS2_v2"
    auto_scaling_enabled = true
    max_pods             = 50
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    only_critical_addons_enabled = true
    os_disk_size_gb              = 30
    temporary_name_for_rotation  = "defaulttemp"
    type                         = "VirtualMachineScaleSets"
    tags = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    upgrade_settings = {
      max_surge = "50%"
    }
    zones     = [3]
    max_count = 3
    min_count = 1
  }
  azure_policy_enabled             = true
  http_application_routing_enabled = false
  identity = {
    type     = "UserAssigned"
    identity = "aks"
  }
  local_account_disabled = true
  key_vault_secrets_provider = {
    secret_rotation_enabled = true
  }
  oidc_issuer_enabled = false # @todo set this to true
  network_profile = {
    network_plugin      = "azure"
    network_mode        = null
    network_policy      = "azure"
    dns_service_ip      = null
    network_data_plane  = "azure"
    network_plugin_mode = null
    outbound_type       = "loadBalancer"
    service_cidr        = null
    ip_versions         = ["IPv4"]
    load_balancer_sku   = "standard"
    pod_cidrs           = []
  }
  workload_identity_enabled = false # @todo set this to true
  sku_tier                  = "Standard"
  storage_profile = {
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }
  kubernetes_cluster_node_pool = {
    infrateam = {
      vm_size             = "Standard_DS2_v2"
      enable_auto_scaling = true
      mode                = "user"
      min_count           = "1"
      max_count           = "2"
      node_taints         = ["app=infrateam:NoSchedule"]
      node_labels         = { "app" = "infrateam" }
    },
  }
  aks_extension = {}
}

#------------------
# Role Assignments
#------------------
role_assignments = {}