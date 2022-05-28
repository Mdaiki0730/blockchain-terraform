// docdb setting
resource "aws_docdb_subnet_group" "service" {
  name       = "${var.prefix}-docdb-subnet"
  subnet_ids = [var.subnet_private_2a_id, var.subnet_private_2c_id]
}

resource "aws_docdb_cluster" "blockchain" {
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.prefix}-docdb-snapshot"
  db_subnet_group_name      = aws_docdb_subnet_group.service.name
  cluster_identifier        = "${var.prefix}-docdb-cluster"
  engine                    = "docdb"

  master_username = var.db_master_username
  master_password = var.db_master_password

  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.service.name
  vpc_security_group_ids          = [aws_security_group.docdb.id]
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "docdb-cluster-${count.index}"
  cluster_identifier = aws_docdb_cluster.blockchain.id
  instance_class     = "db.t3.medium"
}

resource "aws_docdb_cluster_parameter_group" "service" {
  family = "docdb4.0"
  name   = "${var.prefix}-docdb-parameter-group"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

// sg setting
resource "aws_security_group" "docdb" {
  name   = "${var.prefix}-docudb"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allowd_secutiry" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "-1"
  source_security_group_id = var.allowed_security_group_id
  security_group_id        = aws_security_group.docdb.id
}
