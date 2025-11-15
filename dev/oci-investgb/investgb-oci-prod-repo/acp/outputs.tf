output "instance_id" {
  description = "Instance ID"
  value       = oci_core_instance.sit_acp_db_instance.id
}

output "instance_boot_volume_id" {
  description = "Instance Boot Volume ID"
  value       = oci_core_instance.sit_acp_db_instance.boot_volume_id
}

output "instance_private_ip" {
  description = "Instance Private IP"
  value       = oci_core_instance.sit_acp_db_instance.private_ip
}