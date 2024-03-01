resource "aws_db_subnet_group" "education" {
  name       = "education"
  subnet_ids = ["subnet-06563712c6d2cb34d", "subnet-0f34bff22fcd3f363"]

  tags = {
    Name = "Education"
  }
}

resource "aws_db_instance" "education" {
  identifier             = "education03"
  instance_class         = var.instance_class
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = var.engine_version
  username               = "edu"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = ["sg-08ad0b8c3703423eb"]
  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = true
  skip_final_snapshot    = true
  backup_retention_period = 7
  storage_encrypted       = true
}

resource "aws_db_parameter_group" "education" {
  name   = "education"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_parameter_group" "education2" {
  name   = "education15"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

# resource "aws_db_instance" "education_replica" {
#    #name                   = "education-replica"
#    identifier             = "education03-replica"
#    replicate_source_db    = aws_db_instance.education.identifier
#    instance_class         = var.instance_class
#    apply_immediately      = true
#    publicly_accessible    = true
#    skip_final_snapshot    = true
#    vpc_security_group_ids = ["sg-08ad0b8c3703423eb"]
#    parameter_group_name   = aws_db_parameter_group.education.name
# }


