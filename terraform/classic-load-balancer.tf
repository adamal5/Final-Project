# Create public facing load balancer and connect to instances in private subnets
resource "aws_elb" "pub-lb" {
  name               = "public-elb"
  subnets            = ["subnet-0d34663f30d07b049"]
  security_groups    = [aws_security_group.jenkins-sg.id]
  instances          = [aws_instance.Jenkins.id]

#   listener {
#     instance_port     = 8080
#     instance_protocol = "tcp"
#     lb_port           = 8080
#     lb_protocol       = "tcp"
#   }

  listener {
    instance_port     = 8080
    instance_protocol = "HTTP"
    lb_port           = 8080
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "TCP:8080"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}