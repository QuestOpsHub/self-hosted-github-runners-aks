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

#----------------
# Resource Group
#----------------
variable "resource_group" {}

#-----------------
# Virtual Network
#-----------------
variable "virtual_network" {}

#------------------------
# User Assigned Identity
#------------------------
variable "user_assigned_identity" {}

#--------------------
# Container Registry
#--------------------
variable "container_registry" {}

#--------------------------
# Azure Kubernetes Cluster
#--------------------------
variable "aks" {}

variable "AKS-Admins_OBJECT_ID" {}

variable "admin_username" {}

variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAhV6McSnW7VaX7H6Hc+TYowDb8/ZQf04hUKmOCUAQ/2VEuMzXXCt3CF7EIxw3dluu3fDBclgI4lItVMVFUb0CakmDFh5nrIPG4wmhv5weg+OY3rChvrrswNTmHL8q5IKevgMxK9v8Otaejpn4HKuNusm+jKJ5iYfYr4PfoKD636dZx7VuQwjisyfzfE16n99PcIhhb6T6P+gb0XZztWavagJv1P14wUWPRVrUREINQqqOLKqvtRnPYXWrQ8t8abE3iTMqdfzPLURKoLmBOIBb2m+BWEsgnQVXZiPSLhKc1uVC8vFwm5cKaS4g0YH0/qIiQwyrasrTixGCg9dOHjU4IGjD//YzRHuTFEV2DnQgMLU47hVcsNlcvadqiJ/iuG+fCQkz3W5vieWTo58Su0rNXJharlWVHFTUmbi8NarBkCoT55B41gBSLY+7RXO/uDoRQ7/PKHPedmC0UklVcN8Eomh940zOJIWJDkcNyUvd3akvlsTwQnJGbWNkRB/NKNxZSegNTE7nYYPHCnEFBMk46rUmEh+M/HWbx4gChixT38hWQx56cpiYR3uoEzHv83wYjByP4nmQ8+3IuB6bRExz4fb8c0iWkcqaKU0mvYuPp4U++pom9PjwGQExdrrkEnW5yP/wiB270N9E/ob+UOJFXtoA9HWQcvThYUxR2eMVbQ== VeeraBhadraDevOps@LAPTOP-30EPVRQ6"
}

variable "admin_password" {}

#------------------
# Role Assignments
#------------------
variable "role_assignments" {}