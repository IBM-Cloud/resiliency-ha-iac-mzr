/**
#################################################################################################################
*                           Variable Section for the Load Balancer Module.
*                                 Start Here for the Variable Section 
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
* Name: prefix
* Type: String
* Desc: This is the prefix text that will be prepended in every resource name created by this script.
**/
variable "prefix" {
  description = "This is the prefix text that will be prepended in every resource name created for this module."
  type        = string
}

/**
* Name: app_lb_type
* Desc: This variable will hold the App Load Balancer type
* Type: String
**/
variable "app_lb_type" {
  description = "This variable will hold the App Load Balancer type"
  type        = string
}

/**
* Name: web_lb_type
* Desc: This variable will hold the Web Load Balancer type
* Type: String
**/
variable "web_lb_type" {
  description = "This variable will hold the Load Balancer type"
  type        = string
}

/**
* Name: alb_port
* Type: number
* Desc: This is the Application load balancer listener port
**/
variable "alb_port" {
  description = "This is the Application load balancer listener port"
  type        = number
}

/**
* Name: wlb_port
* Type: number
* Desc: This is the Web load balancer listener port
**/
variable "wlb_port" {
  description = "This is the Web load balancer listener port"
  type        = number
}

/**
* Name: vpc_id
* Type: String
* Desc: This is the vpc ID which will be used for Load Balancer module. We are passing this vpc_id from main.tf
**/
variable "vpc_id" {
  description = "Required parameter vpc_id"
  type        = string
}

/**
* Name: subnets
* Type: list
* Desc: Map of subnet objects
**/
variable "subnets" {
  description = "All subnet objects. This is required parameter"
  type = object({
    app = list(any)
    db  = list(any)
    web = list(any)
  })
}

/**
* Name: lb_sg
* Type: string
* Desc: Load balancer security group ID to be attached with load balancers
**/
variable "lb_sg" {
  description = "Load Balancer Security Group"
  type        = string
}

/**
* Name: lb_protocol
* Type: map(any)
* Desc: LBaaS Protocols
**/
variable "lb_protocol" {
  description = "LBaaS protocols"
  type        = map(any)
}

/**
* Name: lb_algo
* Type: map(any)
* Desc: LBaaS backend distribution algorithm
**/
variable "lb_algo" {
  description = "LBaaS backend distribution algorithm"
  type        = map(any)
}

/**
* Name: lb_protocol_value
* Type: string
* Desc: LBaaS Protocols
**/
variable "lb_protocol_value" {
  description = "LBaaS Protocols \nThe protocol could be any of the values: http, https, tcp. \nDefault Value: http"
  type        = string
}

/**
* Name: lb_algo_value
* Type: string
* Desc: LBaaS backend distribution algorithm
**/
variable "lb_algo_value" {
  description = "LBaaS backend distribution algorithm. \nThe algorithm could be any of the values: round_robin, weighted_round_robin, least_connections. \nDefault Value: round_robin"
  type        = string
}

/**
* Name: zones
* Type: map(any)
* Desc: Region and zones mapping
**/
variable "zones" {
  description = "List of Availability Zones where compute resource will be created"
  type        = list(any)
}

/**               
#################################################################################################################
*                                   End of the Variable Section 
#################################################################################################################
**/
