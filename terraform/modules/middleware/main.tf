module "ec2"{
    source = "../ec2"
    service_definition = var.service_definition
    count = can(var.service_definition.Resources.EC2) ? 1 : 0
}