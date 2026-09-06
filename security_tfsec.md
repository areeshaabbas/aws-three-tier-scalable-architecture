## tfsec Security Scan

The Terraform configuration was also scanned using tfsec.

The scan initially reported 15 potential issues:

* 6 Critical
* 4 High
* 3 Medium
* 2 Low

The findings were reviewed individually rather than blindly suppressing or fixing every scanner warning.

### Findings Addressed

| Finding                            | Action                                                               |
| ---------------------------------- | -------------------------------------------------------------------- |
| `aws-ec2-no-public-ip-subnet`      | Public subnets were changed to avoid automatic public IP assignment. |
| `aws-rds-specify-backup-retention` | RDS backup retention was explicitly configured to 7 days.            |

### Intentional Exceptions

| Finding                                 | Decision  | Reason                                                                                                                                                                      |
| --------------------------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `aws-elb-http-not-used`                 | Accepted  | The current project intentionally uses HTTP. HTTPS/ACM is outside the current scope.                                                                                        |
| `aws-ec2-no-public-ingress-sgr`         | Accepted  | The ALB is intentionally the public entry point and must accept internet traffic.                                                                                           |
| `aws-ec2-no-public-egress-sgr`          | Accepted  | The current architecture uses required outbound connectivity, particularly for EC2 bootstrap and AWS service access.                                                        |
| `aws-elb-alb-not-public`                | Accepted  | The ALB must be internet-facing for the three-tier architecture.                                                                                                            |
| `aws-iam-no-policy-wildcards`           | Accepted  | The VPC Flow Logs IAM policy uses the permissions required by the current CloudWatch logging implementation. Further least-privilege refinement is a future hardening step. |
| `aws-rds-specify-backup-retention`      | Addressed | Seven-day backup retention was explicitly configured.                                                                                                                       |
| `builtin.aws.rds.aws0176`               | Accepted  | RDS IAM authentication is not used because the application uses Secrets Manager-managed database credentials.                                                               |
| `builtin.aws.rds.aws0177`               | Accepted  | RDS deletion protection remains disabled so the disposable learning environment can be destroyed with Terraform.                                                            |
| `aws-rds-enable-performance-insights`   | Accepted  | Performance Insights is unnecessary for the scope and scale of this learning project.                                                                                       |
| `aws-cloudwatch-log-group-customer-key` | Accepted  | Customer-managed KMS encryption would add unnecessary complexity and cost for the short-lived learning environment.                                                         |

### Overall Security Assessment

The scans were used as security review tools rather than as a requirement to achieve a perfect scanner score.

The most important architectural controls remain:

**Internet → Public ALB → Private EC2 → Private RDS**

The application and database are isolated from direct public access, EC2 uses IMDSv2, database credentials are managed through Secrets Manager, storage is encrypted, and VPC Flow Logs are enabled.

The remaining findings are primarily production-hardening recommendations or intentional trade-offs for a learning environment.
