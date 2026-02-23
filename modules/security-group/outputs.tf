output "sg_info" {
  description = "Map containing Security Group information including ID and name for each application"
  value = {
    for key, sg in aws_security_group.sg : key => {
      "sg_id"   = sg.id
      "sg_name" = sg.name
      "sg_arn"  = sg.arn
      "application" = try(sg.tags_all.application, "")
    }
  }
}
