## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ibm"></a> [ibm](#provider\_ibm) | 1.42.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_is_lb.app_lb](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb) | resource |
| [ibm_is_lb.web_lb](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb) | resource |
| [ibm_is_lb_listener.app_listener](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_listener) | resource |
| [ibm_is_lb_listener.web_listener](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_listener) | resource |
| [ibm_is_lb_pool.app_pool](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_pool) | resource |
| [ibm_is_lb_pool.web_pool](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_lb_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_port"></a> [alb\_port](#input\_alb\_port) | This is the Application load balancer listener port | `number` | n/a | yes |
| <a name="input_app_lb_type"></a> [app\_lb\_type](#input\_app\_lb\_type) | This variable will hold the App Load Balancer type | `string` | n/a | yes |
| <a name="input_lb_algo"></a> [lb\_algo](#input\_lb\_algo) | LBaaS backend distribution algorithm | `map(any)` | n/a | yes |
| <a name="input_lb_algo_value"></a> [lb\_algo\_value](#input\_lb\_algo\_value) | LBaaS backend distribution algorithm. <br>The algorithm could be any of the values: round\_robin, weighted\_round\_robin, least\_connections. <br>Default Value: round\_robin | `string` | n/a | yes |
| <a name="input_lb_protocol"></a> [lb\_protocol](#input\_lb\_protocol) | LBaaS protocols | `map(any)` | n/a | yes |
| <a name="input_lb_protocol_value"></a> [lb\_protocol\_value](#input\_lb\_protocol\_value) | LBaaS Protocols <br>The protocol could be any of the values: http, https, tcp. <br>Default Value: http | `string` | n/a | yes |
| <a name="input_lb_sg"></a> [lb\_sg](#input\_lb\_sg) | Load Balancer Security Group | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | This is the prefix text that will be prepended in every resource name created for this module. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource Group ID is used to separate the resources in a group. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | All subnet objects. This is required parameter | <pre>object({<br>    app = list(any)<br>    db  = list(any)<br>    web = list(any)<br>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Required parameter vpc\_id | `string` | n/a | yes |
| <a name="input_web_lb_type"></a> [web\_lb\_type](#input\_web\_lb\_type) | This variable will hold the Load Balancer type | `string` | n/a | yes |
| <a name="input_wlb_port"></a> [wlb\_port](#input\_wlb\_port) | This is the Web load balancer listener port | `number` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | List of Availability Zones where compute resource will be created | `list(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_dns"></a> [lb\_dns](#output\_lb\_dns) | Private IP for App, DB and Web Server |
| <a name="output_lb_private_ip"></a> [lb\_private\_ip](#output\_lb\_private\_ip) | Private IP for App and DB Server |
| <a name="output_lb_public_ip"></a> [lb\_public\_ip](#output\_lb\_public\_ip) | Public IP for Web Server |
| <a name="output_objects"></a> [objects](#output\_objects) | This variable will contains the objects of LB, LB Pool and LB Listeners. |
