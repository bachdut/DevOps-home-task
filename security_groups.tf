# Commented out because it's not needed with LocalStack
# resource "aws_security_group" "allow_web" {
#   name        = "allow_web_traffic"
#   description = "Allow web traffic"
#   vpc_id      = aws_vpc.my_vpc.id
#
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "allow_web_traffic"
#   }
# }