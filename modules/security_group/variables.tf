/**
#################################################################################################################
*                           Variable Section for the Security Group Module.
*                                 Start Here of the Variable Section 
#################################################################################################################
*/

/**
* Name: resource_group_name
* Type: String
*/
variable "resource_group_name" {
  description = "Resource group name from your IBM Cloud account where the VPC resources should be deployed."
  type        = string
}

/**
* Name: bastion_sg
* Type: String
*/
variable "bastion_sg" {
  description = "Bastion Security Group ID"
  type        = string
}

/**
* Name: prefix
* Type: String
* Description: This is the prefix text that will be prepended in every resource name created by this script.
**/
variable "prefix" {
  description = "Prefix for all the resources."
  type        = string
}

/**
* Name: alb_port
* Type: number
* Description: This is the Application load balancer listener port
**/
variable "alb_port" {
  description = "This is the Application load balancer listener port"
  type        = number
}

/**
* Name: vpc_id
* Type: String
* Description: This is the vpc ID which will be used for security group module. We are passing this vpc_id from main.tf
**/
variable "vpc_id" {
  description = "Required parameter vpc_id"
  type        = string
}

/**               
#################################################################################################################
*                                   End of the Variable Section 
#################################################################################################################
**/
