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


