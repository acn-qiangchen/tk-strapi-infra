output "alb_endpoint" {
  value = "http://${module.alb.dns_name}/admin"
}