output "security_group_ids" {
  value = {
    dmz        = aws_security_group.dmz.id
    app        = aws_security_group.app.id
    middleware = aws_security_group.middleware.id
    mgmt       = aws_security_group.mgmt.id
  }
}