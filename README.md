# Highly Available Three-Tier Web Architecture on AWS with Terraform

[![Terraform Security & Validation](https://github.com/areeshaabbas/aws-three-tier-scalable-architecture/actions/workflows/terraform-ci.yml/badge.svg)]

A production-grade, highly available three-tier cloud infrastructure built on AWS using Terraform. This project features zero-trust network segregation, automated scaling, database credential rotation with Secrets Manager, and Infrastructure as Code (IaC) security scanning integrated into CI/CD.

---

## 🏛️ Architecture Overview

The system is deployed within a custom VPC spanning two Availability Zones:

```mermaid
flowchart TD
    subgraph Internet ["🌐 Public Internet"]
        User["End Users"]
    end

    subgraph AWS_Cloud ["AWS Cloud (VPC: 10.0.0.0/16)"]
        IGW["Internet Gateway"]
        
        subgraph Public_Subnets ["Public Subnets (Multi-AZ)"]
            ALB["Application Load Balancer (ALB)<br/>SG: Allow 80/443 from 0.0.0.0/0"]
            NAT["NAT Gateway"]
        end

        subgraph App_Subnets ["Private App Subnets (Multi-AZ)"]
            ASG["Auto Scaling Group (EC2 Instances)<br/>Flask Web App (:8080)<br/>SG: Allow :8080 from ALB SG only"]
        end

        subgraph DB_Subnets ["Private Data Subnets (Multi-AZ)"]
            RDS[("Amazon RDS MySQL (:3306)<br/>Storage Encrypted<br/>SG: Allow :3306 from EC2 SG only")]
        end
        
        SM["AWS Secrets Manager<br/>(RDS Credentials)"]
        CW["CloudWatch Log Group<br/>(VPC Flow Logs)"]
    end

    User -->|HTTP Requests| IGW
    IGW --> ALB
    ALB -->|Forward :8080| ASG
    ASG -->|Port 3306| RDS
    ASG -.->|IAM Auth| SM
    AWS_Cloud -.->|VPC Flow Logs| CW
    ASG -->|Egress Updates| NAT
    NAT --> IGW