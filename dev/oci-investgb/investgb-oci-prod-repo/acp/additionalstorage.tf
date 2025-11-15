resource "oci_core_volume" "additional_storage" {
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "${local.instance_display_name}-additional-storage"
  size_in_gbs         = 700

}

resource "oci_core_volume_attachment" "additional_storage_attachment" {
  volume_id       = oci_core_volume.additional_storage.id
  instance_id     = oci_core_instance.sit_acp_db_instance.id
  attachment_type = "paravirtualized"
}
