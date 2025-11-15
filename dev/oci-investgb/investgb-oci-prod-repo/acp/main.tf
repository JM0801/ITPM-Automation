resource "oci_core_instance" "sit_acp_db_instance" {

  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = var.display_name
  shape               = var.instance_config.instance_shape

  create_vnic_details {
    subnet_id                 = var.subnet_id #data.oci_core_subnet.instance_subnet.id
    assign_public_ip          = false
    hostname_label            = var.assign_private_dns_record ? var.name : null
    nsg_ids                   = var.nsg_ids
    assign_private_dns_record = var.assign_private_dns_record
  }

  shape_config {

    memory_in_gbs             = var.instance_config.memory
    ocpus                     = var.instance_config.ocpus
    baseline_ocpu_utilization = var.baseline_ocpu_utilization
  }

  source_details {
    source_id               = var.instance_config.instance_image
    source_type             = var.instance_config.instance_source_type
    boot_volume_size_in_gbs = var.instance_config.boot_volume_size
    kms_key_id              = var.kms_key_id
  }


  metadata = {
    ssh_authorized_keys = file("${path.module}/ssh_authorised_keys")
    user_data           = var.user_data
  }
  /*
  dynamic "agent_config" {
    for_each = var.cloud_agent_config

    content {
      are_all_plugins_disabled = agent_config.value.are_all_plugins_disabled
      is_management_disabled   = agent_config.value.is_management_disabled
      is_monitoring_disabled   = agent_config.value.is_monitoring_disabled

      dynamic "plugins_config" {
        for_each = var.cloud_agent_plugins

        content {
          desired_state = plugins_config.value.state
          name          = plugins_config.value.name
        }
      }
    }
  }*/

  /*
  dynamic "instance_options" {
    for_each = var.instance_options

    content {
      are_legacy_imds_endpoints_disabled = instance_options.value.are_legacy_imds_endpoints_disabled
    }
  }

  dynamic "platform_config" {
    for_each = var.platform_config

    content {
      is_secure_boot_enabled             = platform_config.value.is_secure_boot_enabled
      is_trusted_platform_module_enabled = platform_config.value.is_trusted_platform_module_enabled
      is_measured_boot_enabled           = platform_config.value.is_measured_boot_enabled
      type                               = platform_config.value.type
    }
  } */


  //defined_tags  = var.defined_tags
  //freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [
      defined_tags,
      metadata["user_data"]
    ]
  }

}




