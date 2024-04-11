provider "aws"{
    region = "ap-south-1"
}

locals{
    config = yamldecode(file("services.yml"))
    services = local.config["services"]
}

module "microservices"{
    for_each = toset(local.services)
    source = "./modules/middleware"
    service_definition = yamldecode(file("./services/${each.key}.yml"))
}

