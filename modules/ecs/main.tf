// vpc endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  tags = {
    Name = "${var.prefix}-vpce-ecr-api"
  }
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-west-2.ecr.api"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpce.id
  ]

  subnet_ids = [
    var.subnet_private_2a_id,
    var.subnet_private_2c_id
  ]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  tags = {
    Name = "${var.prefix}-vpce-ecr-dkr"
  }
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-west-2.ecr.dkr"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpce.id
  ]

  subnet_ids = [
    var.subnet_private_2a_id,
    var.subnet_private_2c_id
  ]
}

resource "aws_vpc_endpoint" "logs" {
  tags = {
    Name = "${var.prefix}-vpce-logs"
  }
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-west-2.logs"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpce.id
  ]
  subnet_ids = [
    var.subnet_private_2a_id,
    var.subnet_private_2c_id
  ]
}

resource "aws_vpc_endpoint" "ssm" {
  tags = {
    Name = "${var.prefix}-vpce-ssm"
  }
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-west-2.ssm"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpce.id
  ]
  subnet_ids = [
    var.subnet_private_2a_id,
    var.subnet_private_2c_id
  ]
}

resource "aws_vpc_endpoint" "s3" {
  tags = {
    Name = "${var.prefix}-vpce-s3"
  }
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "private_2a" {
  route_table_id  = var.route_table_private_2a_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "private_2c" {
  route_table_id  = var.route_table_private_2c_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

// iam role setting
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ssm-read-policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

// cloud watch setting
resource "aws_cloudwatch_log_group" "wallet-backend" {
  name              = "/ecs/project/dev/wallet-backend"
  retention_in_days = 30
}

// ecs setting
resource "aws_ecs_task_definition" "main" {
  family = var.prefix

  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "wallet-backend",
    "image": "${var.ecr_image_uri}",
		"logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-west-2",
        "awslogs-stream-prefix": "wallet-backend",
        "awslogs-group": "/ecs/project/dev/wallet-backend"
      }
    },
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
		"secrets": [
			{
        "name": "REST_PORT",
        "valueFrom": "arn:aws:ssm:us-west-2:976862162552:parameter/REST_PORT"
      },
      {
        "name": "GRPC_PORT",
        "valueFrom": "arn:aws:ssm:us-west-2:976862162552:parameter/GRPC_PORT"
      },
      {
        "name": "MONGO_DB_URI",
        "valueFrom": "arn:aws:ssm:us-west-2:976862162552:parameter/MONGO_DB_URI"
      }
		]
  }
]
TASK_DEFINITION
}

resource "aws_ecs_cluster" "main" {
  name = var.prefix
}

resource "aws_ecs_service" "main" {
  name = var.prefix

  cluster         = aws_ecs_cluster.main.name
  launch_type     = "FARGATE"
  desired_count   = "1"
  task_definition = aws_ecs_task_definition.main.arn
  network_configuration {
    subnets         = ["${var.subnet_private_2a_id}", "${var.subnet_private_2c_id}"]
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = "wallet-backend"
    container_port   = "8080"
  }
}


// sg setting
resource "aws_security_group" "ecs" {
  name        = "${var.prefix}-ecs"
  description = "${var.prefix} ecs"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-ecs"
  }
}

resource "aws_security_group" "vpce" {
  name        = "${var.prefix}-sg-vpce"
  description = "sg vpce"
  vpc_id      = var.vpc_id

  ingress {
    description     = "container sg"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.prefix}-sg-vpce"
  }
}
