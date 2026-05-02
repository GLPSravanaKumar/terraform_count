account_id       = "glps-prod-sa"
vm_name       = [ "glps-prod-vm","glps-test-vm"]
machine_type     = "e2-medium"
zone             = [ "asia-south1-a", "asia-south1-b"]
image            = "ubuntu-os-cloud/ubuntu-2204-lts"
vpc_name         = "glps-prod-vpc"
subnet_name   = "glps-prod-subnet"
subnet_cidr   = [ "10.0.10.0/24", "10.0.20.0/24"]
region           = "asia-south1"
firewall_name = "glps-prod-firewall"

