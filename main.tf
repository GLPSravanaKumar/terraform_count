resource "google_service_account" "server_sa" {
  account_id   = var.account_id
  display_name = "Service Account for  Server VM"
}

resource "google_compute_instance" "server_vm" {
  count = length(var.vm_name)
  name         = var.vm_name[count.index]
  machine_type = var.machine_type
  zone         = var.zone[count.index]

  tags = ["server", "glps-prod"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }


  network_interface {
    network    = google_compute_network.prod_vpc.id
    subnetwork = google_compute_subnetwork.subnet[count.index].id

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = file("userdata.sh")

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.server_sa.email
    scopes = ["cloud-platform"]
  }
}



