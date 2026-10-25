
# AWS VPC Peering — EWB Student Project

**Student:** Mohan Kumar K  
**Region configured:** `ap-south-1` (Mumbai)  
**Status:** Infrastructure code and documentation package. **Not deployed or AWS-tested.**

This project defines two non-overlapping VPCs connected by a VPC peering connection. VPC A has a public bastion host and one private workload. VPC B has one private workload and no Internet Gateway. The two private workloads are intended to communicate over private IPv4 addresses after peering routes and security rules are applied.

## Architecture and CIDRs

| Resource | CIDR / private IP | Internet exposure |
|---|---|---|
| VPC A `ewb-vpc-a` | `10.10.0.0/16` | Has an IGW |
| Public subnet `ewb-a-public` | `10.10.1.0/24` | Default route to IGW |
| Bastion `ewb-bastion` | `10.10.1.10` | Public IPv4 assigned by AWS |
| Private subnet `ewb-a-private` | `10.10.2.0/24` | No default internet route |
| App-A `ewb-app-a` | `10.10.2.10` | No public IPv4 |
| VPC B `ewb-vpc-b` | `10.20.0.0/16` | No IGW |
| Private subnet `ewb-b-private` | `10.20.1.0/24` | No default internet route |
| App-B `ewb-app-b` | `10.20.1.10` | No public IPv4 |

See `docs/architecture_diagram.svg` and `docs/project_report.md`.

## Important limitation

No AWS account/access was provided for this project. Terraform has **not** been applied, so IDs, active peering status, successful connectivity, and screenshots do not exist yet. The report intentionally labels test results as **not run** rather than inventing evidence. Do not submit placeholder outputs as real test results.

## Prerequisites if you later get an AWS lab account

- Terraform 1.5 or newer
- AWS CLI configured with credentials for the lab account
- OpenSSH client
- Permission to create VPC, route tables, peering, security groups, EC2 and key pairs
- An EC2 key pair named `ewb-lab` in `ap-south-1`; retain its `.pem` file locally
- Confirm credits and current AWS pricing before launching anything

## Files

- `terraform/`: Terraform configuration for the VPCs, peering, routes, security groups and three EC2 instances
- `ssh/config.template`: SSH aliases using ProxyJump through the bastion
- `tests/test_runner.sh`: post-deployment checks; requires a real AWS deployment
- `docs/architecture_diagram.svg`: planned architecture, not deployment evidence
- `docs/project_report.md`: report template with explicit evidence placeholders

## Static review steps (no AWS account required)

From the `terraform` folder:

```bash
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

`terraform init -backend=false` can still require internet access to download the provider. These commands check formatting/provider-schema validity; they do not prove that AWS resources can be created. If Terraform is not installed, install it first or use a Terraform-aware editor. Do not claim validation succeeded unless you ran it and observed success.

## Deployment steps (only with authorized AWS access)

1. Create the `ewb-lab` EC2 key pair in Mumbai and save the downloaded PEM securely as `~/.ssh/ewb-lab.pem`. Never commit it.
2. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`.
3. Replace `student_public_ip` with your current public IPv4 address.
4. Run `terraform init`, `terraform fmt -check`, `terraform validate`, and `terraform plan`.
5. Review the plan and costs carefully before `terraform apply`.
6. Configure `ssh/config` from `ssh/config.template`, replacing `BASTION_PUBLIC_IP` with the real Terraform output. Protect the private key (`chmod 400 ~/.ssh/ewb-lab.pem` on Linux/WSL).
7. Capture real output/screenshots for peering state, routes, security groups, private instance public-IP fields, ping, SSH ProxyJump, controlled failure and recovery.
8. Run `terraform destroy` after collecting the evidence and confirm resources are deleted.

### Controlled baseline test

The variable `enable_peering_routes` is `true` by default. To intentionally test the no-peering-route baseline, change it to `false` and apply that change only in an authorized lab account. App-A can still be reached through the bastion, but its ping to App-B should fail because the route is absent. Then set it back to `true` and apply again. This is a destructive infrastructure change and should not be attempted without permission.

## Cost and security notes

- EC2 instances, EBS volumes and public IPv4 addresses can incur charges. No NAT Gateway is created.
- The bastion SSH rule is restricted to one public IPv4 `/32`; update it if your public IP changes.
- The application hosts have no public IPv4. They have no default internet route.
- Security groups are stateful, but routes are still needed in both directions for cross-VPC traffic.
- Do not publish AWS access keys, private keys, account IDs, or unredacted credentials.
