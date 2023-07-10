terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider for us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
# Create VPC in us-east-1
resource "aws_vpc" "VPC_us_east_1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "VPC-us-east-1"
  }
}
resource "aws_subnet" "PUBSUB1" {
  vpc_id     = aws_vpc.VPC_us_east_1.id
  cidr_block = "10.0.1.0/24"
availability_zone="us-east-1a"
  tags = {
    Name = "PUBSUB1"
  }
}
resource "aws_subnet" "PVTSUB1" {
  vpc_id     = aws_vpc.VPC_us_east_1.id
  cidr_block = "10.0.2.0/24"
availability_zone="us-east-1b"
  tags = {
    Name = "PVTSUB1"
  }
}
resource "aws_internet_gateway" "TFIGW1" {
  vpc_id = aws_vpc.VPC_us_east_1.id

  tags = {
    Name = "TFIGW1"
  }
}
resource "aws_route_table" "PUBRT1" {
  vpc_id = aws_vpc.VPC_us_east_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TFIGW1.id
  }

   tags = {
    Name = "PUBRT1"
  }
}
resource "aws_route_table_association" "PubRTass1" {
  subnet_id      = aws_subnet.PUBSUB1.id
  route_table_id = aws_route_table.PUBRT1.id
}
resource "aws_eip" "TFEIP1" {
  vpc      = true
}
resource "aws_nat_gateway" "TFNAT1" {
  allocation_id = aws_eip.TFEIP1.id
  subnet_id     = aws_subnet.PUBSUB1.id

  tags = {
    Name = "TFNAT1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_nat_gateway.TFNAT1]
}

resource "aws_route_table" "PVTRT1" {
  vpc_id = aws_vpc.VPC_us_east_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TFIGW1.id
  }

   tags = {
    Name = "PVTRT1"
  }
}
resource "aws_route_table_association" "PvtRTass1" {
  subnet_id      = aws_subnet.PVTSUB1.id
  route_table_id = aws_route_table.PVTRT1.id
}
# Create Amazon RDS Aurora in us-east-1 private subnet
resource "aws_db_instance" "rds_aurora_us_east_1" {
  engine               = "aurora"
  engine_version       = "5.7.mysql_aurora.2.08.0"
  instance_class       = "db.t3.small"
  name                 = "rds-aurora-us-east-1"
  username             = "admin"
  password             = "admin123"
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group_us_east_1.name
}

# Create DB subnet group for us-east-1
resource "aws_db_subnet_group" "db_subnet_group_us_east_1" {
  name        = "db-subnet-group-us-east-1"
  subnet_ids  = [aws_subnet.PVTSUB1.id]
}
# Configure the AWS Provider for us-east-2
provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}
# Create VPC in us_east_2
resource "aws_vpc" "VPC_us_east_2" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC_us_east_2"
  }
}
resource "aws_subnet" "PUBSUB2" {
  vpc_id     = aws_vpc.VPC_us_east_2.id
  cidr_block = "10.0.3.0/24"
  availability_zone="us-east-2a"
  tags = {
    Name = "PUBSUB2"
  }
}
resource "aws_subnet" "PVTSUB2" {
  vpc_id     = aws_vpc.VPC_us_east_2.id
  cidr_block = "10.0.4.0/24"
  availability_zone="us-east-2b"
  tags = {
    Name = "PVTSUB2"
  }
}
resource "aws_internet_gateway" "TFIGW2" {
  vpc_id = aws_vpc.VPC_us_east_2.id

  tags = {
    Name = "TFIGW2"
  }
}
resource "aws_route_table" "PUBRT2" {
  vpc_id = aws_vpc.VPC_us_east_2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TFIGW2.id
  }

   tags = {
    Name = "PUBRT2"
  }
}
resource "aws_route_table_association" "pubRTass2" {
  subnet_id      = aws_subnet.PUBSUB2.id
  route_table_id = aws_route_table.PUBRT2.id
}
resource "aws_eip" "TFEIP2" {
  vpc      = true
}
resource "aws_nat_gateway" "TFNAT2" {
  allocation_id = aws_eip.TFEIP2.id
  subnet_id     = aws_subnet.PUBSUB2.id

  tags = {
    Name = "TFNAT2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_nat_gateway.TFNAT2]
}

resource "aws_route_table" "PVTRT2" {
  vpc_id = aws_vpc.VPC_us_east_2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TFIGW2.id
  }

   tags = {
    Name = "PVTRT2"
  }
}
resource "aws_route_table_association" "PvtRTass2" {
  subnet_id      = aws_subnet.PVTSUB2.id
  route_table_id = aws_route_table.PVTRT2.id
}
# Create Amazon RDS Aurora read replica in us-east-2 private subnet
resource "aws_db_instance" "rds_aurora_replica_us_east_2" {
  engine             = "aurora"
  engine_version     = "5.7.mysql_aurora.2.08.0"
  instance_class     = "db.t3.small"
  name               = "rds-aurora-replica-us-east-2"
  username           = "admin"
  password           = "admin123"
  db_subnet_group_name  = aws_db_subnet_group.db_subnet_group_us_east_2.name
}

# Create DB subnet group for us-east-2
resource "aws_db_subnet_group" "db_subnet_group_us_east_2" {
  name        = "db-subnet-group-us-east-2"
  subnet_ids  = [aws_subnet.PVTSUB2.id]
}

# Configure cross-region replication for us-east-1 Aurora instance
resource "aws_rds_cluster" "rds_aurora_cluster_us_east_1" {
  engine               = "aurora"
  engine_version       = "5.7.mysql_aurora.2.08.0"
  availability_zones    = aws_subnet.PVTSUB1.availability_zone
  database_name        = "mydb"
  master_username      = "admin"
  master_password      = "admin123"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group_us_east_1.name

  tags = {
    Name = "RDS-Aurora-Cluster-us-east-1"
  }
}

# Create DB subnet group for cross-region replication
resource "aws_db_subnet_group" "db_subnet_group_cross_region" {
  name        = "db-subnet-group-cross-region"
  subnet_ids  = [aws_subnet.PVTSUB1.id, aws_subnet.PVTSUB2.id]
}

# Configure cross-region replication for us-east-1 Aurora instance
resource "aws_rds_cluster_instance" "rds_aurora_replica_us_east_2" {
  identifier             = "rds-aurora-replica-us-east-2"
  engine                 = "aurora"
  engine_version         = "5.7.mysql_aurora.2.08.0"
  instance_class         = "db.t3.small"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group_cross_region.name
  cluster_identifier = aws_rds_cluster.rds_aurora_cluster_us_east_1.id

  tags = {
    Name = "RDS-Aurora-Replica-us-east-2"
  }
}
