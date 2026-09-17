# AWS High-Availabity Web Architecture (ALB+ASG)

An enterprise-grade, fault-tolerant, adn dynamic web infrastructure deployed on AMazon web services (aws) utilizing an **Application load balancer** and **Auto Scaling Group** across multiple Availability Zones.

---

![AWS architecture Diagram](/docs/architecture-diagram.drawio.png)





## Network & Port Specification 


| Component | Identifier / Name | Network / CIDR / Port | Scope / Location | Description & Architectural Function |
| :--- | :--- | :--- | :--- | :--- |
| **Cloud Region** | `us-east-1` | N/A | Global AWS Infrastructure | Primary deployment region for Multi-AZ redundancy. |
| **Virtual Private Cloud** | `VPC` | `10.0.0.0/16` | Region (`us-east-1`) | Isolated virtual network container for all project resources. |
| **Internet Gateway** | `IGW` | `0.0.0.0/0` | VPC Edge | Provides public Internet ingress and egress routing for the VPC. |
| **Availability Zone A** | `us-east-1a` | Physical Datacenter A | `us-east-1` | Primary fault-domain zone for compute redundancy. |
| **Availability Zone B** | `us-east-1b` | Physical Datacenter B | `us-east-1` | Secondary fault-domain zone for Multi-AZ resiliency. |
| **Public Subnet A** | `Public subnet A` | `10.0.1.0/24` | `us-east-1a` | Public subnet hosting load balancer endpoints and compute nodes. |
| **Public Subnet B** | `Public subnet B` | `10.0.2.0/24` | `us-east-1b` | Secondary public subnet enabling Multi-AZ web distribution. |
| **Load Balancer** | `Application Load Balancer` | HTTP / Port `80` | Multi-AZ (`us-east-1a`, `us-east-1b`) | Layer 7 load balancer distributing ingress web traffic. |
| **Auto Scaling Group** | `Auto Scaling group` | Capacity: Min 2, Max 4 | Spans Subnets A & B | Manages elastic lifecycle and self-healing for EC2 nodes. |
| **Compute Instances** | `EC2 Instance (Apache)` | Port `80` (HTTP) | `Public Subnet A` & `B` | Web servers bootstrapped dynamically with `user-data.sh`. |

---


## Security Group Rules & Network Isolation

### 1. ALB Security Group 

Public-facing perimeter security boundary protecting the Application Load Balancer


| Traffic Direction | Protocol | Port Range | Source / Destination | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Inbound** | TCP | `80` (HTTP) | `0.0.0.0/0` (Anywhere) | Accepts public client web traffic from the Internet. |
| **Outbound** | TCP | `80` (HTTP) | `ec2-sg` (Security Group) | Forwards validated client requests to EC2 targets. |


### 2. Compute Security Group - *Security Group Chaining*

Internal compute perimeter restricting direct acess to web servers.


| Traffic Direction | Protocol | Port Range | Source / Destination | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Inbound** | TCP | `80` (HTTP) | `alb-sg` (Security Group ID) | **SG Chaining:** Strictly permits traffic coming **only** from the ALB. |
| **Outbound** | ALL | ALL | `0.0.0.0/0` | Allows OS package updates (`yum`) and metadata fetching. |

---


## Key Architectural Principles

### Perimeter Isolation via Security Group Chaining

To prevent anauthorized access, compute nodes do not express Port 80 directly to the public internet:

* The ingress rule for 'ec2-sg' references the logical ID of 'alb-sg' rather than an IP range.
* Any request attempting to bypass the Application Load Balancer by calling the EC2 IP directly is dropped at the AWS hypervisor level.

### High Availability & Fault Tolerance

* **Multi-AZ Deployment** Deploying across 'us-east-1a' and 'us-east-1b' ensures continuos operation if an entire AWS datacenter experiences an outage.
* **Automated Health Checks** The ALB continuosly probes '/index.html' via HTTP '200 OK' checks. Unhealthy instances are automatically deregistered.
* **Self-Healing Infrastructure** The Auto Scaling Group enforces a mininum capacity of 2 nodes. If an instances fails, the ASG terminates it and provisions a replacement node automatically.

---

## Repository Structure

```text
aws-ha-web-architecture/
├── docs/
│   └── architecture-diagram.png
├── scripts/
│   └── user-data.sh
├── .gitignore
└── README.md
```

---

## Automated Instances Bootstrapping 

Compute nodes are dynamically provisioned upon launch using 'scripts/user-data.sh':

1. Updates Linux system packages ('yum update').
2. Installs and enables the Apache Web Server ('httpd').
3. Fetches dynamic metadata via **IMDSv2** (Instance ID and Availability Zone) to server dynamic HTML page for load-balancing verification.

---

## Verification & Testing Procedures

* **Load Balancing Test** Refreshing the ALB DNS URL routes traffic sequentially between 'us-east-1a' and 'us-east-1b'.
* **Failover Test** Terminating an instances in AWS Console triggers the ASG to launch a fresh replacement without service disruption.

---

## Live Deployment & healthy Verification

### 1. Multi-AZ Load Balancing Verification

Traffic distribution confirmed across multiple Availability Zones via application Load Balancer:

![AZ-A Response](docs/demo-az-a.png)

![AZ-B Response](docs/demo-az-b.png)

### 2. Target Group Health Status 

All compute targets passing HTTP 200 OK health probes:

![Target Group Health](docs/target-group-healthy.png)




