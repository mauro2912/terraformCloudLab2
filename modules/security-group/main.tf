resource "aws_security_group" "sg" {
  for_each = var.sg_config
  
  name        = join("-", [var.client, var.functionality, var.environment, "sg", each.value.application])
  description = each.value.description
  vpc_id      = each.value.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      description     = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = merge(
    { Name = join("-", [var.client, var.functionality, var.environment, "sg", each.value.application]) },
    { id_case = each.value.ticket },
    { accessclass = each.value.accessclass },
    { application = each.value.application }
  )
}
