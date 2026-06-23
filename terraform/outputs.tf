output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.mysql.endpoint
  sensitive   = true
}

output "monitoring_public_ip" {
  description = "Public IP of monitoring instance"
  value       = aws_instance.monitoring.public_ip
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.drupal.name
}
