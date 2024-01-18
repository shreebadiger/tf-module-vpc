output "vpc_id" {
    value = aws_vpc.main.id
}

output "public_subnet" {
    value = aws_subnet.public.*.id
}
output "web_subnet" {
    value = aws_subnet.web.*.id
}
output "app_subnet" {
    value = aws_subnet.app.*.id
}
output "db_subnet" {
    value = aws_subnet.db.*.id
}