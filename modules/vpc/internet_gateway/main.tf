resource "aws_internet_gateway" "main" {
  count  = var.create_igw > 0 ? 1 : 0
  vpc_id = var.vpc_id
  tags = merge(
    { Name = "${join("-", tolist([var.client, var.functionality, var.environment, "igw", "public"]))}" },
    { id_case = var.ticket },
    {accessclass = "public" }
  )
}

