#################################################################################################
#################################################################################################

# This Terraform file defines the variables used in this Terraform scripts for this repo.
# Input variable allowing users to customize aspects of the configuration when used directly 
# (e.g. via CLI, .tfvars file or via environment variables), or as a module (via module arguments)

#################################################################################################
#################################################################################################

locals {

  alb_port = 80 # App load balancer listener port
  wlb_port = 80 # Web load balancer listener port

  zones = {
    "us-south" = ["us-south-1", "us-south-2", "us-south-3"] #Dallas
    "us-east"  = ["us-east-1", "us-east-2", "us-east-3"]    #Washington DC
    "eu-gb"    = ["eu-gb-1", "eu-gb-2", "eu-gb-3"]          #London
    "eu-de"    = ["eu-de-1", "eu-de-2", "eu-de-3"]          #Frankfurt
    "jp-tok"   = ["jp-tok-1", "jp-tok-2", "jp-tok-3"]       #Tokyo
    "au-syd"   = ["au-syd-1", "au-syd-2", "au-syd-3"]       #Sydney
    "jp-osa"   = ["jp-osa-1", "jp-osa-2", "jp-osa-3"]       #Osaka
    "br-sao"   = ["br-sao-1", "br-sao-2", "br-sao-3"]       #Sao Paulo
    "ca-tor"   = ["ca-tor-1", "ca-tor-2", "ca-tor-3"]       #Toronto
  }
}

##################################################################################################
############################## User Input Variables Section ####################################
##################################################################################################

/**
* Name: api_key
* Type: String
* Desc: This is the API key for the IBM Cloud account used to create the resources. 
*/
variable "api_key" {
  description = "This is the API key for the IBM Cloud account used to create the resources. [Learn more](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui)"
  type        = string
  sensitive   = true
}

/**
* Name: region
* Type: String
* Desc: Select the region from the dropdown list where the VPC resources will be deployed.
*/
variable "region" {
  description = "Select the region from the dropdown list where the VPC resources will be deployed."
  type        = string
}

/**
* Name: user_ssh_key
* Type: String
* Desc: Comma-separated list of names of SSH key configured in your IBM Cloud account that is used to establish a connection to the bastion server. Ensure the SSH key is present in the same region where the 3-tier app is being deployed.
*       If you don't have an existing key, then create one using <ssh-keygen -t rsa -b 4096 -C "user_ID"> command. And create a ssh key in IBM cloud with the public contents of file ~/.ssh/id_rsa.pub.
**/
variable "user_ssh_keys" {
  description = "Comma-separated list of names of SSH key configured in your IBM Cloud account that is used to establish a connection to the bastion server. Ensure the SSH key is present in the same region where the 3-tier app is being deployed. [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)"
  type        = string
}

locals {
  user_ssh_key_list = [for x in split(",", var.user_ssh_keys) : trimspace(x)]
}

/**
* Name: resource_group_name
* Type: String
* Desc: Resource group name from your IBM Cloud account where the VPC resources will be deployed.
*/
variable "resource_group_name" {
  description = "Resource group name from your IBM Cloud account where the VPC resources will be deployed."
  type        = string
  validation {
    condition     = length(var.resource_group_name) == 32
    error_message = "Length of Resource Group ID should be 32 characters."
  }
}

/**
* Name: prefix
* Type: String
* Desc: An alphanumeric prefix identifier that will be added to the beginning of all of the VPC resources. It should end with a hyphen (-) and does not exceed 11 characters
**/
variable "prefix" {
  description = "An alphanumeric prefix identifier that will be added to the beginning of all of the VPC resources. It should end with a hyphen (-) and does not exceed 11 characters"
  type        = string
  validation {
    condition     = length(var.prefix) <= 11
    error_message = "Length of prefix should be less than 11 characters."
  }
  validation {
    condition     = can(regex("^[A-Za-z][-0-9A-Za-z]*-$", var.prefix))
    error_message = "For the prefix value only a-z, A-Z and 0-9 are allowed, the prefix should start with a character, and the prefix should end a with hyphen(-)."
  }
}
 