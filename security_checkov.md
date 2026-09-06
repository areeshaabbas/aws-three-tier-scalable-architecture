# Security Review

## Infrastructure Security Scanning

Terraform infrastructure was scanned using Checkov to identify security and compliance issues.

The goal was not to make every Checkov check pass blindly. Findings were reviewed based on the architecture, project scope, security impact, and additional cost/complexity.

## Security Controls Implemented

* RDS is deployed in private subnets.
* RDS does not have public access.
* RDS storage encryption is enabled.
* RDS credentials are managed through AWS Secrets Manager.
* EC2 accesses the database through security-group-to-security-group rules.
* EC2 is not directly exposed to the internet.
* ALB is deployed in public subnets.
* EC2 instances are deployed in private subnets.
* IMDSv2 is required on EC2 instances.
* EC2 EBS volumes are encrypted.
* VPC Flow Logs are enabled.
* Terraform state uses an S3 backend with encryption and versioning.
* DynamoDB is used for Terraform state locking.
* S3 public access is blocked for the Terraform state bucket.
* DynamoDB Point-in-Time Recovery is enabled.
* ALB invalid HTTP header fields are rejected.

## Intentional Checkov Exceptions

Some Checkov findings were intentionally not implemented because they are outside the scope of this learning project or would require significant architectural changes.

| Finding                             | Decision                | Reason                                                                                                                                                            |
| ----------------------------------- | ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ALB HTTPS / TLS checks              | Accepted                | Current project uses HTTP to keep the initial architecture simple. HTTPS would require ACM certificate configuration and an HTTPS listener.                       |
| HTTP → HTTPS redirect               | Accepted                | HTTPS is outside the current project scope.                                                                                                                       |
| ALB WAF                             | Accepted                | WAF is production hardening and is not required for this project.                                                                                                 |
| ALB deletion protection             | Accepted                | The infrastructure is intentionally disposable for Terraform practice and testing.                                                                                |
| RDS deletion protection             | Accepted                | `terraform destroy` is intentionally used during the learning project.                                                                                            |
| RDS Multi-AZ                        | Accepted                | Multi-AZ would increase cost and is not required to demonstrate the architecture.                                                                                 |
| RDS IAM authentication              | Accepted                | The application uses Secrets Manager-managed database credentials instead.                                                                                        |
| RDS enhanced monitoring             | Accepted                | Additional monitoring infrastructure and cost are unnecessary for the current scope.                                                                              |
| CloudWatch log-group KMS encryption | Accepted                | The project uses a short retention period and does not require a customer-managed KMS key.                                                                        |
| CloudWatch one-year retention       | Accepted                | Seven-day retention is sufficient for this learning environment.                                                                                                  |
| S3 cross-region replication         | Accepted                | The Terraform state bucket is a project-level learning resource rather than a production disaster-recovery system.                                                |
| S3 access logging                   | Accepted                | Additional logging infrastructure is outside the current scope.                                                                                                   |
| S3 lifecycle configuration          | Accepted                | Not required for the current state-management demonstration.                                                                                                      |
| S3 event notifications              | Accepted                | No event-driven workflow is required by the project.                                                                                                              |
| S3 customer-managed KMS encryption  | Accepted                | Server-side encryption with AES-256 is already enabled; a customer-managed KMS key is unnecessary for this project.                                               |
| ALB HTTP access from the internet   | Accepted                | The ALB is intentionally the public entry point of the three-tier architecture.                                                                                   |
| Target-group HTTP                   | Accepted                | ALB-to-EC2 communication occurs inside the VPC. End-to-end TLS is considered a future production hardening step.                                                  |
| Broad security-group egress         | Accepted where required | EC2 requires outbound HTTPS access for AWS APIs/bootstrap operations, while the architecture otherwise restricts inbound traffic through security-group chaining. |
| Public-subnet public-IP mapping     | Accepted if retained    | Public subnets are intentionally used for internet-facing infrastructure such as the ALB/NAT Gateway.                                                             |

## Security Philosophy

Security findings were evaluated according to risk rather than simply attempting to achieve a 100% scanner score.

The architecture follows the principle of minimizing public exposure:

**Internet → ALB → EC2 → RDS**

The database remains private, EC2 instances are not directly internet-facing, and security groups restrict communication between application tiers.

Future production improvements could include HTTPS with ACM, AWS WAF, RDS Multi-AZ, deletion protection, enhanced monitoring, centralized logging, stricter egress rules, and additional disaster-recovery controls.
