#-----------------
# Storage Account
#-----------------
data "azurerm_storage_account" "storage_account" {
  name                = "sttfbackend928475"
  resource_group_name = "rg-tf-backend"
}

data "azurerm_client_config" "current" {}

#------------------------
# User Assigned Identity
#------------------------
data "azurerm_user_assigned_identity" "aks-agentpool" {
  name                = "${data.terraform_remote_state.hub.outputs.aks.name}-agentpool"
  resource_group_name = "MC_rg-${var.helpers.project_short}-hub-${var.helpers.environment}-${var.helpers.region_short}-${data.terraform_remote_state.hub.outputs.random_string.result}_${data.terraform_remote_state.hub.outputs.aks.name}_${var.helpers.region}"
}