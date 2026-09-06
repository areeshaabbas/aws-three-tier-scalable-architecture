resource "aws_lb_target_group" "target" {
  target_type = "instance"
  name        = "my-target"
  protocol    = "HTTP"
  port        = var.app_port
  vpc_id      = aws_vpc.my-vpc.id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = tostring(var.app_port)
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "flask-target-group"
  }
}

resource "aws_lb" "lb-main" {
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  internal           = false
  name               = "app-alb"

  subnets = [
    aws_subnet.public-1.id,
    aws_subnet.public-2.id
  ]

  tags = {
    Name = "my-lb"
  }
  drop_invalid_header_fields = true
}

resource "aws_lb_listener" "lb-listen" {
  load_balancer_arn = aws_lb.lb-main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}