Here's a README file tailored to your Terraform configuration:

```markdown
# AWS Web Server Setup with Terraform

This repository contains a Terraform configuration to set up a web server on AWS. The configuration includes an EC2 instance, security group, key pair, SSM parameter for the private key, and an Application Load Balancer (ALB) with listeners for HTTP and HTTPS.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 0.12
- AWS credentials configured (using `aws configure` or environment variables)

## Setup and Deployment

### Step 1: Clone the repository

```sh
git clone https://github.com/yourusername/your-repo.git
cd your-repo
```

### Step 2: Initialize Terraform

```sh
terraform init
```

### Step 3: Review and Apply the Configuration

Ensure you review the configuration to understand what resources will be created.

To create the resources:

```sh
terraform apply
```

You will be prompted to confirm before applying the changes. Type `yes` to proceed.

### Step 4: Access the Web Server

Once the resources are created, you can access your web server using the public DNS of the load balancer, which will be provided in the Terraform output.

## Configuration

### Variables

You can customize the configuration by modifying the values in the `terraform.tfvars` file or by passing variables directly using the `-var` flag.

### Example `terraform.tfvars`

```hcl
region = "us-east-1"
```

### Default Values

| Variable            | Description                          | Default       |
|---------------------|--------------------------------------|---------------|
| `region`            | AWS region to deploy resources       | `us-east-1`   |
| `key_name`          | Name of the SSH key pair             | `web-server-key` |
| `instance_type`     | EC2 instance type                    | `t2.micro`    |
| `vpc_id`            | VPC ID to deploy resources           | `<Your VPC ID>` |
| `public_subnets`    | List of public subnets               | `<Your Subnets>` |

## Resources

This Terraform configuration will create the following resources:

- AWS Key Pair
- TLS Private Key
- AWS SSM Parameter to store the private key
- AWS Security Group with rules for SSH, HTTP, HTTPS, and a custom port
- AWS EC2 instance
- AWS Application Load Balancer with HTTP and HTTPS listeners
- AWS ACM Certificate

### Security Group Rules

| Port | Protocol | Source        | Description                 |
|------|----------|---------------|-----------------------------|
| 22   | TCP      | 0.0.0.0/0     | SSH access                  |
| 80   | TCP      | 0.0.0.0/0     | HTTP access                 |
| 443  | TCP      | 0.0.0.0/0     | HTTPS access                |
| 3000 | TCP      | 0.0.0.0/0     | Custom port (e.g., for app) |

## Outputs

| Output        | Description                      |
|---------------|----------------------------------|
| `instance_id` | ID of the created EC2 instance   |

## Clean Up

To destroy all resources created by this Terraform configuration:

```sh
terraform destroy
```

You will be prompted to confirm before destroying the resources. Type `yes` to proceed.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Maintainers

- [Beknazar Saitov](https://github.com/yourusername)

```

