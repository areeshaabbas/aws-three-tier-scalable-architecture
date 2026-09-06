output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.my-vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public-1.id, aws_subnet.public-2.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private-1.id, aws_subnet.private-2.id]
}

output "alb_security_group_id" {
  description = "ID of the ALB Security Group"
  value       = aws_security_group.alb-sg.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 Security Group"
  value       = aws_security_group.ec2-sg.id
}

output "rds_security_group_id" {
  description = "ID of the RDS Security Group"
  value       = aws_security_group.rds-sg.id
}

output "rds_endpoint" {
  description = "RDS connection endpoint"
  value       = aws_db_instance.db.endpoint
}

output "rds_address" {
  description = "RDS connection hostname (without port)"
  value       = aws_db_instance.db.address
}

output "alb_dns_name" {
  description = "Public DNS URL of the Application Load Balancer"
  value       = aws_lb.lb-main.dns_name
}

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = aws_lb_target_group.target.arn
}