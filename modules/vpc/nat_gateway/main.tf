resource "aws_nat_gateway" "gw" {
  count         = length(var.nat_config) > 0 ? length(var.nat_config) : 0
  subnet_id     = var.nat_config[count.index].subnet_id
  allocation_id = aws_eip.nat_gateway[count.index].id

  tags = merge(
    { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "nat", count.index + 1]))}" },
    { accessclass = "public" }
  )
}

resource "aws_eip" "nat_gateway" {
  count = length(var.nat_config) > 0 ? length(var.nat_config) : 0
  tags = merge(
    { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "eip", count.index + 1]))}" },
    { accessclass = "public" }
  )
}
