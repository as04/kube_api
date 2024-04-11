output "app" {
  value = "http://${module.microservices["api"].ec2[0].eip.public_ip}/health"
}