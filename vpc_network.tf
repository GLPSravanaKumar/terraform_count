resource "google_compute_network" "prod_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  description             = "Production VPC for  server infrastructure"
}

resource "google_compute_subnetwork" "subnet" {
  count = length(var.subnet_cidr)
  name          = "${var.subnet_name}-${count.index}"
  ip_cidr_range = var.subnet_cidr[count.index]
  region        = var.region
  network       = google_compute_network.prod_vpc.id
  description   = " server subnet in production VPC"
}

resource "google_compute_firewall" "server_firewall" {
  name        = var.firewall_name
  network     = google_compute_network.prod_vpc.id
  description = "Firewall rules for server traffic"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["server"]
}
