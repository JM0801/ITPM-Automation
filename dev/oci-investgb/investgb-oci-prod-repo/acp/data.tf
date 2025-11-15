data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "rhel_image" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8.10"
}