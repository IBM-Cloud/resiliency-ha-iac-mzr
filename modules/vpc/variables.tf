/**
#################################################################################################################
*                           Variable Section for the VPC Module.
*                           Start Here of the Variable Section 
#################################################################################################################
*/

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
* Name: resource_group_name
* Type: String
*/
variable "resource_group_name" {
  description = "Resource group name from your IBM Cloud account where the VPC resources should be deployed."
  type        = string
}

/**               
#################################################################################################################
*                                   End of the Variable Section 
#################################################################################################################
**/