/**
----------------------------------------------------------------|
* Total Resource Count for the default value of this project:   |
----------------------------------------------------------------|
* VPC Count                     = 1
* Public Gateway                = 3 [will incur cost]
* Subnet Count                  = 9
* Security Group Count          = 5
* Security Group Rules          = 18
* Load Balancers                = 2 [will incur cost]
* Load Balancer Listener        = 2
* Load Balancer Pool            = 2
* Bastion VSI                   = 1 [will incur cost]
* Instance Template             = 2
* Instance Group                = 2
* Instance Group Manager        = 2
* Instance Group Policy         = 8
* Instance Group Members        = 2 [will incur cost]
* Database VSI                  = 2 [will incur cost]
* Time Sleep                    = 2
* Data Volume                   = 2 [will incur cost]
* Null Resource                 = 1
* Data Source Auth Token        = 1
* Data Source ssh_key           = 1
* Dynamic ssh_key               = 1
* Floating ip                   = 1 [will incur cost]

*--------------------------------------|
*--------------------------------------|
* Total Resources               = 71   |
*--------------------------------------|
*--------------------------------------|
**/


/**
* Calling the VPC module with the following required parameters
* source: Path of the Source Code of the VPC Module
* prefix: This is the prefix text that will be pre-pended in every resource name created by this module.
* resource_group_name: The resource group ID
**/

module "vpc" {
  source              = "./modules/vpc"
  prefix              = var.prefix
  resource_group_name = var.resource_group_name
}

/**
* Data Resource
* Element : SSH Key
* This will return the ssh key/keys ID of the User-ssh-key. This is the existing ssh key/keys of user which will be used to login to Bastion server.
**/
data "ibm_is_ssh_key" "ssh_key_id" {
  count = length(local.user_ssh_key_list)
  name  = local.user_ssh_key_list[count.index]
}

/**
* Calling the Bastion module with the following required parameters
* source: Source Directory of the Module
* prefix: This will be appended in resources created by this module
* vpc_id: VPC ID to contain the subnets
* enable_floating_ip: Determines whether to create Floating IP or not
* user_ssh_key: This is the list of the existing ssh keys of user which will be used to login to Bastion server. Its private key content should be there in path ~/.ssh/id_rsa 
    And public key content should be uploaded to IBM cloud. If you don't have an existing key then create one using ssh-keygen -t rsa -b 4096 -C "user_ID" command.
* bastion_ssh_key: This key will be created dynamically on the bastion VSI. It will be used to login to Web/App/DB servers via Bastion.
* public_ip_address_list: List of User's Public IP addresses in the format X.X.X.X/32 which will be used to login to Bastion VSI
* resource_group_name: The resource group id
* zones: List of zones for the provided region. If region is us-south then zones would be ["us-south-1","us-south-2","us-south-3"]
* api_key: Api key of user which will be used to login to IBM cloud in provisioner section
* region: User specified Region code
* bastion_profile: The Profile needed for Bastion VSI creation
* bastion_os_type: OS image to be used [windows | linux] for Bastion server
* bastion_image: The Bastion Image needed for Bastion VSI creation
* bastion_ip_count: IP count is the total number of total_ipv4_address_count for Bastion Subnet
* depends_on: This ensures that the subnet and security group object will be created before the bastion
**/

module "bastion" {
  source                 = "./modules/bastion"
  prefix                 = var.prefix
  vpc_id                 = module.vpc.id
  enable_floating_ip     = local.enable_floating_ip
  user_ssh_key           = data.ibm_is_ssh_key.ssh_key_id.*.id
  bastion_ssh_key        = var.bastion_ssh_key_var_name
  public_ip_address_list = local.public_ip_address_list
  resource_group_name    = var.resource_group_name
  zones                  = local.zones[var.region]
  api_key                = var.api_key
  region                 = var.region
  bastion_profile        = var.bastion_profile
  bastion_image          = var.bastion_image
  bastion_ip_count       = var.bastion_ip_count
  depends_on             = [module.vpc]
}

# /**
# * Data Resource
# * Element : SSH Key
# * This will return the ssh key ID of the Bastion-ssh-key. This is the dynamically generated ssh key from bastion server itself.
# * This key will be attached to all the app servers.
# *
# * Note: If you get this error on terraform apply -> Error: No SSH Key found with name {prefix}-bastion-ssh-key
# * Then with terraform destroy command use -refresh=false flag at this time only.
# * DO NOT use this flag on any other time, As it stops the state refresh.
# * Now, before re-running the script -> Check the Bastion server image version. If it is windows, 
# * It should be "Windows Server 2019 Standard Edition (amd64) ibm-windows-server-2019-full-standard-amd64-6" only.
# **/

data "ibm_is_ssh_key" "bastion_key_id" {
  name = "${var.prefix}${var.bastion_ssh_key_var_name}"
  depends_on = [
    module.bastion,
  ]
}

/**
* Calling the Public Gateway module with the following required parameters
* source: Path of the Source Code of the Public Gateway Module
* vpc_id: VPC ID for the the Public Gateway Module. Public Gateways will be created inside this VPC.
* prefix: This is the prefix text that will be pre-pended in every resource name created by this module.
* resource_group_name: The resource group ID
* zones: List of zones for the provided region. If region is us-east then zones would be ["us-east-1","us-east-2","us-east-3"]
* depends_on: This ensures that the vpc object will be created before the Public Gateway Module
**/
module "public_gateway" {
  source              = "./modules/public_gateway"
  vpc_id              = module.vpc.id
  prefix              = "${var.prefix}region-"
  resource_group_name = var.resource_group_name
  zones               = local.zones[var.region]
  depends_on          = [module.vpc]
}

/**
* Locals
* This resource will be used to create and calculate local variables containing Subnet IP count.
* If there is a requirement for extra ips please update the db_ip_count with extra required ips.
**/
locals {
  valid_ip_counts = [8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384]
  web_ip_count    = ceil(var.web_max_servers_count / length(local.zones[var.region])) + 5 + 2 # 5:reservedIP, 2:load_balancer  
  app_ip_count    = ceil(var.app_max_servers_count / length(local.zones[var.region])) + 5 + 2 # 5:reservedIP, 2:load_balancer      
  db_ip_count     = var.db_vsi_count + 5                                                      # db_vsi_count:total_db_count, 5:reservedIP

  ip_count = {
    "web" = [for valid_web_ip_count in local.valid_ip_counts : valid_web_ip_count if valid_web_ip_count > local.web_ip_count][0]
    "app" = [for valid_app_ip_count in local.valid_ip_counts : valid_app_ip_count if valid_app_ip_count > local.app_ip_count][0]
    "db"  = [for valid_db_ip_count in local.valid_ip_counts : valid_db_ip_count if valid_db_ip_count > local.db_ip_count][0]
  }
}

/**
* Calling the Subnet module with the following required parameters
* source: Path of the Source Code of the Subnet Module
* vpc_id: VPC ID for the the Subnet Module. Subnets will be created inside this VPC.
* prefix: This is the prefix text that will be pre-pended in every resource name created by this module.
* resource_group_name: The resource group ID
* zones: List of zones for the provided region. If region is us-south then zones would be ["us-south-1","us-south-2","us-south-3"]
* ip_count: Total number of IP Address for each subnet
* db_vsi_count: Total Database instances that will be created in the user specified region.
* public_gateway_ids: List of ids of all the public gateways of region 1 where subnets will get attached
* depends_on: This ensures that the vpc object will be created before the Subnet Module
**/
module "subnet" {
  source              = "./modules/subnet"
  vpc_id              = module.vpc.id
  prefix              = var.prefix
  resource_group_name = var.resource_group_name
  zones               = local.zones[var.region]
  ip_count            = local.ip_count
  db_vsi_count        = var.db_vsi_count
  public_gateway_ids  = module.public_gateway.pg_ids
  depends_on          = [module.vpc]
}

/**
* Calling the Security Group module with the following required parameters
* source: Source Directory of the Module
* vpc_id: VPC ID to contain the subnets
* prefix: This will be appended in resources created by this module
* resource_group_name: The resource group id
* alb_port: This is the Application load balancer listener port
* app_os_type: Provide App servers OS flavour
* web_os_type: Provide Web servers OS flavour
* db_os_type: Provide Db servers OS flavour
* depends_on: This ensures that the vpc and subnet object will be created before the security groups
**/

module "security_group" {
  source              = "./modules/security_group"
  vpc_id              = module.vpc.id
  prefix              = var.prefix
  resource_group_name = var.resource_group_name
  alb_port            = local.alb_port
  bastion_sg          = module.bastion.bastion_sg
  depends_on          = [module.vpc, module.subnet]
}

/**
* Calling the Load Balancer module with the following required parameters
* source: Source Directory of the Module
* vpc_id: VPC ID to contain the subnets
* prefix: This will be appended in resources created by this module
* resource_group_name: The resource group id
* zones: List of zones for the provided region. If region is us-south then zones would be ["us-south-1","us-south-2","us-south-3"]
* lb_sg: load balancer security group to be attached with all the load balancers.
* subnets: We are passing the Map of subnet objects. It includes all the subnet IDs
* alb_port: This is the Application load balancer listener port
* lb_type_private: This variable will hold the Load Balancer type as private
* lb_type_public: This variable will hold the Load Balancer type as public
* lb_protocol: LBaaS protocols
* lb_algo: LBaaS backend distribution algorithm
* lb_port_number: declare LBaaS pool member port number
* depends_on: This ensures that the vpc, subnet and security group object will be created before the load balancer
**/

module "load_balancer" {
  source              = "./modules/load_balancer"
  vpc_id              = module.vpc.id
  prefix              = var.prefix
  resource_group_name = var.resource_group_name
  zones               = local.zones[var.region]
  lb_sg               = module.security_group.sg_objects["lb"].id
  subnets             = module.subnet.sub_objects
  alb_port            = local.alb_port
  wlb_port            = local.wlb_port
  lb_protocol_value   = local.lb_protocol_value
  lb_algo_value       = local.lb_algo_value
  app_lb_type         = local.app_lb_type
  web_lb_type         = var.web_lb_type
  lb_protocol         = local.lb_protocol
  lb_algo             = local.lb_algo
  depends_on          = [module.vpc, module.subnet, module.security_group]
}

/**
* Calling the Instance module with the following required parameters
* source: Source Directory of the Module
* prefix: This will be appended in resources created by this module
* vpc_id: VPC ID to contain the subnets
* ssh_key: This ssh_key got generated dynamically on the bastion server and further will be attached with all the other VSI to be connected from Bastion Server only
* resource_group_name: The resource group id
* zones: List of zones for the provided region. If region is us-south then zones would be ["us-south-1","us-south-2","us-south-3"]
* bandwidth: Bandwidth per second in GB. The possible values are 3, 5 and 10
* data_vol_size: Storage size in GB. The value should be between 10 and 2000
* db_image: Image ID to be used with DB VSI
* db_profile: Hardware configuration profile for the DB VSI
* db_vsi_count: Total Database instances that will be created in the user specified region.
* tiered_profiles: Tiered profiles for Input/Output per seconds in GBs
* subnets: Subnet ID for the Database VSI
* db_sg: Security group ID to be attached with DB VSI
* depends_on: This ensures that the subnets, security group and bastion object will be created before the instance
**/

module "instance" {
  source              = "./modules/instance"
  prefix              = var.prefix
  vpc_id              = module.vpc.id
  ssh_key             = [data.ibm_is_ssh_key.bastion_key_id.id]
  resource_group_name = var.resource_group_name
  zones               = local.zones[var.region]
  iops_tier           = var.iops_tier
  data_vol_size       = var.data_vol_size
  db_image            = var.db_image
  db_profile          = var.db_profile
  db_vsi_count        = var.db_vsi_count
  tiered_profiles     = local.tiered_profiles
  subnets             = module.subnet.sub_objects["db"].*.id
  db_sg               = module.security_group.sg_objects["db"].id
  depends_on          = [module.subnet.ibm_is_subnet, module.security_group, module.bastion]
}

/**
* Calling the Instance Group module with the following required parameters
* source: Source Directory of the Module
* vpc_id: VPC ID to contain the subnets
* prefix: This will be appended in resources created by this module
* resource_group_name: The resource group id
* zones: List of zones for the provided region. If region is us-south then zones would be ["us-south-1","us-south-2","us-south-3"]
* ssh_key: This ssh_key got generated dynamically on the bastion server and further will be attached with all the other VSI to be connected from Bastion Server only
* subnets: We are passing the Map of subnet objects. It includes all the subnet IDs
* sg_objects: We are passing the Map of security group objects. It includes all the security groups IDs
* objects: This variable will contain the objects of LB, LB Pool and LB Listeners. It includes IDs of load balancer, load balancer pools and load balancer listeners.
* app_image: Image ID to be used with App VSI
* app_config: Application configuration Map
* app_os_type: Provide App OS flavour
* web_os_type: Provide DB OS flavour
* web_image: Image ID to be used with Web VSI
* web_config: Web configuration Map
* web_max_servers_count: Maximum Web servers count for the Web Instance group
* web_min_servers_count: Minimum Web servers count for the Web Instance group
* web_cpu_threshold: Average target CPU Percent for CPU policy of Web Instance Group.
* web_aggregation_window: The aggregation window is the time period in seconds that the instance group manager monitors each instance and determines the average utilization.
* web_cooldown_time: Specify the cool down period, the number of seconds to pause further scaling actions after scaling has taken place.
* app_max_servers_count: Maximum App servers count for the App Instance group
* app_min_servers_count: Minimum App servers count for the App Instance group
* app_cpu_threshold: Average target CPU Percent for CPU policy of App Instance Group.
* app_aggregation_window: The aggregation window is the time period in seconds that the instance group manager monitors each instance and determines the average utilization.
* app_cooldown_time: Specify the cool down period, the number of seconds to pause further scaling actions after scaling has taken place.
* depends_on: This ensures that the vpc and other objects will be created before the instance group
**/

module "instance_group" {
  source                 = "./modules/instance_group"
  vpc_id                 = module.vpc.id
  prefix                 = var.prefix
  resource_group_name    = var.resource_group_name
  zones                  = local.zones[var.region]
  ssh_key                = [data.ibm_is_ssh_key.bastion_key_id.id]
  subnets                = module.subnet.sub_objects
  sg_objects             = module.security_group.sg_objects
  objects                = module.load_balancer.objects
  app_image              = var.app_image
  app_instance_profile   = var.app_instance_profile
  app_config             = local.app_config
  web_image              = var.web_image
  web_config             = local.web_config
  web_instance_profile   = var.web_instance_profile
  web_max_servers_count  = var.web_max_servers_count
  web_min_servers_count  = var.web_min_servers_count
  web_cpu_threshold      = var.web_cpu_threshold
  web_aggregation_window = var.web_aggregation_window
  web_cooldown_time      = var.web_cooldown_time
  app_max_servers_count  = var.app_max_servers_count
  app_min_servers_count  = var.app_min_servers_count
  app_cpu_threshold      = var.app_cpu_threshold
  app_aggregation_window = var.app_aggregation_window
  app_cooldown_time      = var.app_cooldown_time
  depends_on             = [module.bastion, module.load_balancer]
}

