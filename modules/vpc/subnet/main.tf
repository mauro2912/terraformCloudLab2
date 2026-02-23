resource "aws_subnet" "main_subnet" {
  count             = length(var.cidr_blocks) > 0 ? length(var.cidr_blocks) : 0
  availability_zone = var.cidr_blocks[count.index].availability_zone
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_blocks[count.index].cidr_block
  tags = merge(
    { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "subnet", var.cidr_blocks[count.index].service, count.index + 1]))}" },
    { id_case = var.cidr_blocks[count.index].ticket },
    {accessclass = var.cidr_blocks[count.index].accessclass }
  )
}

resource "aws_route_table" "route_table" {
  count  = length(var.cidr_blocks) > 0 ? 1 : 0
  vpc_id = var.vpc_id
  tags   = merge(
    { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "rtb", var.cidr_blocks[0].service]))}" },
    { id_case = var.cidr_blocks[0].ticket },
    {accessclass = var.cidr_blocks[0].accessclass }
  )
}

resource "aws_route_table_association" "subnet_association" {
  count          = length(var.cidr_blocks) > 0 ? length(var.cidr_blocks) : 0
  subnet_id      = aws_subnet.main_subnet[count.index].id
  route_table_id = aws_route_table.route_table[0].id
}

resource "aws_route" "internet_route" {
  count                  = length(var.gateway_id) > 0 ? 1 : 0
  route_table_id         = aws_route_table.route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = var.gateway_id[0]
}

resource "aws_route" "nat_route" {
  count                  = length(var.nat_id) > 0 ? 1 : 0
  route_table_id         = aws_route_table.route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.nat_id[count.index]
}
