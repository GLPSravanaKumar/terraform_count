# Terraform GCP Multi-Zone VM Deployment with Count

This Terraform project automates the deployment of multiple Google Compute Engine (GCE) instances across different zones on Google Cloud Platform (GCP) using the `count` meta-argument.

## Project Overview

This configuration demonstrates best practices for using Terraform's `count` meta-argument to provision scalable infrastructure with minimal code duplication. It creates:

- **Multiple VM Instances**: Deploy multiple Google Compute Engine instances across specified zones
- **Production VPC Network**: A custom Virtual Private Cloud (VPC) network with custom subnets
- **Multiple Subnets**: Subnets in different regions with specified CIDR ranges using count
- **Firewall Rules**: Security rules allowing HTTP, custom ports, and SSH access
- **Service Account**: A dedicated service account for VM authentication with cloud-platform scope

## Prerequisites

- Google Cloud Account with billing enabled
- GCP Project created (Project ID: `devops-493413`)
- Google Cloud SDK installed and authenticated
- Terraform v1.0 or later installed

### Setup Google Cloud Authentication

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project devops-493413
```

## Architecture

```
Production VPC (prod_vpc)
├── Subnet-0 (asia-south1)
│   └── VM Instance-0 (machine_type specified)
├── Subnet-1 (asia-south1)
│   └── VM Instance-1 (machine_type specified)
└── Firewall Rules (Allows: SSH, HTTP, Port 8080)
```

## Using the Count Meta-Argument

The `count` meta-argument is used in this project to efficiently manage multiple resource instances:

### What is Count?

The `count` meta-argument allows you to manage multiple resources of the same type without repeating resource blocks. Instead of copying and pasting resource definitions, you can use a single resource block and iterate over it.

### Count Usage in This Project

#### 1. **VM Instances** (`main.tf`)
```hcl
resource "google_compute_instance" "server_vm" {
  count = length(var.vm_name)
  name         = var.vm_name[count.index]
  machine_type = var.machine_type
  zone         = var.zone[count.index]
  
  # ... other configuration
}
```

- **`count = length(var.vm_name)`**: Creates as many VMs as elements in the `vm_name` list
- **`count.index`**: Accesses the current iteration index (0, 1, 2, ...)
- **`var.vm_name[count.index]`**: Gets the name for each VM from the list

#### 2. **Subnets** (`vpc_network.tf`)
```hcl
resource "google_compute_subnetwork" "subnet" {
  count = length(var.subnet_cidr)
  name          = "${var.subnet_name}-${count.index}"
  ip_cidr_range = var.subnet_cidr[count.index]
  region        = var.region
  network       = google_compute_network.prod_vpc.id
}
```

- Creates multiple subnets based on the `subnet_cidr` list
- Automatically names subnets with index suffixes (e.g., `subnet-0`, `subnet-1`)

### Benefits of Using Count

✅ **Eliminates Code Duplication**: Single resource block for multiple instances
✅ **Scalability**: Easily add or remove resources by modifying variable lists
✅ **Maintainability**: Changes to resource configuration apply to all instances
✅ **Readability**: Clear intent that resources are managed uniformly
✅ **Dynamic**: Number of resources determined by variable values

### Limitations of Count

⚠️ **Resource Addressing**: Use `resource_type.name[index]` to reference individual resources
⚠️ **No Named Index**: Only numeric indexing available (unlike `for_each`)
⚠️ **Index Sensitivity**: Adding/removing elements shifts indices, potentially causing plan diffs

## Configuration Files

- **`main.tf`**: Service account and VM instance definitions using count
- **`vpc_network.tf`**: VPC, subnets (with count), and firewall rules
- **`provider.tf`**: GCP provider configuration
- **`variables.tf`**: Input variable definitions
- **`output.tf`**: Output values for instance IDs, IPs, and network information
- **`terraform.tfvars`**: Variable values file
- **`userdata.sh`**: Startup script executed on VM initialization

## Deployment Instructions

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Review the Plan
```bash
terraform plan
```

Review the resources that will be created:
- Service account
- VM instances
- VPC and subnets
- Firewall rules

### 3. Apply Configuration
```bash
terraform apply
```

Confirm the prompt to create resources.

### 4. Access Your VMs
After deployment, retrieve the public IPs:
```bash
terraform output server_vm_public_ip
```

Connect via SSH:
```bash
ssh -i ~/.ssh/your_key.pub user@<public_ip>
```

## Managing Resources with Count

### Adding More VMs

Update `terraform.tfvars`:
```hcl
vm_name   = ["server-prod-1", "server-prod-2", "server-prod-3"]
zone      = ["asia-south1-a", "asia-south1-b", "asia-south1-c"]
subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
```

Then run:
```bash
terraform plan
terraform apply
```

### Removing VMs

Remove entries from the lists in `terraform.tfvars` and reapply. Terraform will destroy removed resources.

### Modifying Specific Resources

Reference individual resources using count index:
```bash
# Destroy only the second VM (index 1)
terraform destroy -target='google_compute_instance.server_vm[1]'
```

## Outputs

After applying the configuration, Terraform provides:

- **`server_vm_id`**: Instance IDs of created VMs
- **`server_vm_public_ip`**: Public IP addresses for VM access
- **`server_sa_email`**: Service account email
- **`prod_vpc_id`**: VPC network ID

View outputs:
```bash
terraform output
terraform output server_vm_public_ip  # Specific output
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

Confirm the prompt to remove all resources.

## Variables Reference

| Variable | Type | Description |
|----------|------|-------------|
| `account_id` | string | Service account ID |
| `vm_name` | list(string) | Names of VM instances |
| `machine_type` | string | GCE machine type (e.g., `e2-medium`) |
| `zone` | list(string) | Zones for VM instances |
| `image` | string | Boot disk image family |
| `vpc_name` | string | VPC network name |
| `subnet_name` | string | Subnet name prefix |
| `subnet_cidr` | list(string) | CIDR ranges for subnets |
| `region` | string | GCP region |
| `firewall_name` | string | Firewall rule name |

## Troubleshooting

### Quota Exceeded
If you receive quota errors, reduce the number of VMs or request quota increase in GCP Console.

### Authentication Failed
Ensure you've authenticated with `gcloud auth login` and set the correct project.

### Resource Already Exists
Delete the `terraform.tfstate` file and reapply if state is corrupted.

## Best Practices

1. **Use `terraform fmt`** to format code consistently
2. **Use `terraform validate`** to check syntax before apply
3. **Always run `terraform plan`** before apply
4. **Use remote state** for team collaboration (Terraform Cloud or GCS backend)
5. **Use workspaces** for multiple environments (dev, staging, prod)

## Resources Created

- 1 Service Account
- N Google Compute Engine instances (where N = length of vm_name list)
- 1 VPC Network
- M Subnets (where M = length of subnet_cidr list)
- 1 Firewall Rule



##
❌🔴⚠️ Main drawback of the count meta-argument ⚠️🔴❌

🔍 Index-based resource management (BIG problem)
When you use count, Terraform tracks resources by index (0, 1, 2...), not by identity.

resource "aws_instance" "example" {
  count = 3
  ami   = "ami-123"
}
👉 Resources become:
aws_instance.example[0]
aws_instance.example[1]
aws_instance.example[2]

🚨 What goes wrong?
🔴 If list/order changes → resources get destroyed
Example:

count = length(var.servers)
var.servers = ["web", "api", "db"]

Later you change:

var.servers = ["api", "db"]   # removed "web"

👉 Terraform thinks:
index [0] → was "web", now "api" ❌
index [1] → was "api", now "db" ❌

👉 Result:
Resources get replaced/destroyed unnecessarily

💥 Real-world impact
EC2 instances recreated
Data loss risk
Downtime
Unexpected infra changes

❌🔴
##


## License

This project is licensed under the MIT License.

## Support

For issues or questions, refer to:
- [Terraform Documentation](https://www.terraform.io/docs)
- [Google Cloud Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform Count Meta-Argument](https://www.terraform.io/language/meta-arguments/count)
