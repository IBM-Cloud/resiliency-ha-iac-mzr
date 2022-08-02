/**
#################################################################################################################
*                                 Public Gateways Output Variable Section
#################################################################################################################
**/


/**
* Output Variable 
* Element : pg_ids
* This variable will return the ids of the public_gateways created in multiple zones
**/

output "pg_ids" {
  description = "ID's of the public gateways created"
  value       = ibm_is_public_gateway.pg.*.id
}


/**               
#################################################################################################################
*                                   End of the Output Section 
#################################################################################################################
**/
