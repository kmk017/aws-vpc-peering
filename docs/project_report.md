# AWS VPC Peering — Student Project Report

**Student:** Mohan Kumar K  
**Course:** AWS Architect Associate / EWB Cloud Labs  
**Configured region:** `ap-south-1` (Mumbai)  
**Report type:** Design and code documentation  
**Deployment status:** **Not deployed — AWS account/access was not available**  
**Date prepared:** 25 October 2026

> Evidence integrity: this document describes the intended Terraform design. It does not claim that AWS resources were created or that connectivity tests passed. Replace the evidence placeholders only after running the project in an authorized AWS account.

## 1. Objective

Design a private IPv4 connection between two AWS VPCs using VPC peering, explicit route-table associations, least-privilege security groups, and a public bastion host for SSH administration. The two application instances are intended to remain without public IPv4 addresses.

## 2. Planned architecture and inventory

| Resource | Name | CIDR / IP | Planned role |
|---|---|---|---|
| VPC A | `ewb-vpc-a` | `10.10.0.0/16` | Bastion and App-A |
| Public subnet A | `ewb-a-public` | `10.10.1.0/24` | Bastion subnet |
| Private subnet A | `ewb-a-private` | `10.10.2.0/24` | App-A subnet |
| VPC B | `ewb-vpc-b` | `10.20.0.0/16` | App-B workload |
| Private subnet B | `ewb-b-private` | `10.20.1.0/24` | App-B subnet |
| Internet Gateway | `ewb-igw-a` | — | Attached to VPC A only |
| Bastion | `ewb-bastion` | `10.10.1.10` | SSH entry point; public IPv4 assigned by AWS |
| App-A | `ewb-app-a` | `10.10.2.10` | Private workload; no public IPv4 |
| App-B | `ewb-app-b` | `10.20.1.10` | Private workload; no public IPv4 |
| Peering | `ewb-a-b-peer` | AWS-generated ID | Intended private path between VPCs |

Architecture diagram: `architecture_diagram.svg` (design diagram; not evidence of a live deployment).

## 3. Planned route tables

| Route table | Destination | Target | Reason |
|---|---|---|---|
| `ewb-rt-a-public` | `10.10.0.0/16` | local | VPC A local traffic |
| `ewb-rt-a-public` | `0.0.0.0/0` | `ewb-igw-a` | Internet route for bastion subnet |
| `ewb-rt-a-public` | `10.20.0.0/16` | peering connection | Bastion-to-App-B private route |
| `ewb-rt-a-private` | `10.10.0.0/16` | local | VPC A local traffic |
| `ewb-rt-a-private` | `10.20.0.0/16` | peering connection | App-A-to-App-B route |
| `ewb-rt-b-private` | `10.20.0.0/16` | local | VPC B local traffic |
| `ewb-rt-b-private` | `10.10.0.0/16` | peering connection | Return route to VPC A |

The AWS VPC router provides the local route automatically. The Terraform code explicitly creates the additional routes listed above.

## 4. Planned security group rules

| Security group | Inbound rule | Source |
|---|---|---|
| `ewb-sg-bastion` | TCP 22 | Student public IPv4 `/32` |
| `ewb-sg-app-a` | TCP 22 | Bastion `10.10.1.10/32` |
| `ewb-sg-app-a` | ICMP echo request (type 8) | App-B `10.20.1.10/32` |
| `ewb-sg-app-b` | TCP 22 | Bastion `10.10.1.10/32` |
| `ewb-sg-app-b` | ICMP echo request (type 8) | App-A `10.10.2.10/32` |

The Terraform configuration allows outbound traffic from the three security groups. Security groups are stateful; route tables still need valid forward and return routes.

## 5. Intended validation plan

| Test | Procedure | Expected result (not observed) | Actual result |
|---|---|---|---|
| Static Terraform validation | `terraform fmt -check`, `terraform validate` | No syntax/schema errors | **Not run** |
| Baseline route test | Disable peering routes and ping App-B from App-A | Ping fails | **Not run** |
| Peering status | Describe peering connection | `active` | **Not run** |
| Forward ping | App-A to `10.20.1.10` | Replies if routes, SGs and OS permit | **Not run** |
| Reverse ping | App-B to `10.10.2.10` | Replies if routes, SGs and OS permit | **Not run** |
| SSH ProxyJump | SSH to App-B through bastion | Host reached via private IP | **Not run** |
| Controlled failure | Remove App-B inbound ICMP rule | App-A ping fails | **Not run** |
| Recovery | Restore the exact ICMP rule | Ping resumes | **Not run** |
| Private IP check | Inspect App-A and App-B public IP fields | No public IPv4 on either app | **Not run** |
| Cleanup | `terraform destroy` and verify resource list | Lab resources deleted | **Not run** |

### Evidence to add only after a real run

- [ ] Terraform `validate` output
- [ ] Route table/subnet associations
- [ ] Peering connection status
- [ ] Security group inbound rules
- [ ] EC2 instance list showing public IPv4 only for bastion
- [ ] Actual baseline ping output
- [ ] Actual forward and reverse ping output
- [ ] Actual SSH ProxyJump output
- [ ] Actual controlled failure and recovery output
- [ ] Cleanup confirmation

Do not paste expected output into the “actual result” column.

## 6. SSH ProxyJump design

The local OpenSSH client connects to the bastion's public IPv4. `ProxyJump` then forwards the connection through the bastion to the target's private IPv4. App-A and App-B do not require public IPv4 addresses. The bastion security group accepts SSH only from the configured student public IPv4 `/32`; app security groups accept SSH only from the bastion's private address.

## 7. Viva preparation

**Why must both VPC route tables be configured?**  
Each side needs a route to send packets toward the peer VPC. A return route is required so replies can get back to the source.

**Why is VPC peering not the same as an Internet Gateway?**  
Peering provides private routing between the two specified VPCs. It does not give VPC B internet access and does not support transitive routing.

**Why use a bastion host?**  
It provides a controlled administrative entry point so private instances can be accessed without public IPv4 addresses.

**Why can an active peering connection still fail to pass ping?**  
Routes, security group rules, network ACLs, OS behavior and the correct target addresses must all permit the traffic.

**Why is the App-B SSH source the bastion private IP?**  
With SSH ProxyJump, the bastion opens the forwarded TCP connection to App-B, so App-B sees the bastion's private IP as the source of that connection.

## 8. Cost and cleanup

EC2, EBS storage and public IPv4 use may incur charges. No NAT Gateway is included. Before launching resources, verify account credits and current prices. After collecting real evidence, run `terraform destroy` from the same Terraform directory and confirm that the created resources are gone.

## 9. Reflection

This is a design-stage reflection, not a claim of hands-on deployment: the configuration demonstrates how non-overlapping CIDRs, explicit subnet route-table associations, VPC peering, return routes, security groups and a bastion host fit together. A live lab run is still needed to validate the design, observe failures and recovery, and collect submission evidence.
