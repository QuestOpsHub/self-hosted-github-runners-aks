#---------------
# Random String
#---------------
output "random_string" {
  value = module.random_string
}

#----------------
# Resource Group
#---------------
output "resource_group" {
  value = module.resource_group
}

#--------------------
# Container Registry
#--------------------
output "container_registry" {
  value     = module.container_registry
  sensitive = true
}

#--------------------------
# Azure Kubernetes Cluster
#--------------------------
output "aks" {
  value     = module.aks
  sensitive = true
}