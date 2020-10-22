provider "aws" {
  region     = "eu-west-2"
  access_key = ""
  secret_key = ""
}

# Create a vpc
resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "main-gateway" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "main"
  }
}

# Create route table
resource "aws_route_table" "main-route-table" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.main-gateway.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Create subnet 1
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2"
  tags = {
    Name = "jenkins-subnet "
  }
}

# Create subnet 2
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2"
  tags = {
    Name = "test-subnet"
  }
}

# Create subnet 3
resource "aws_subnet" "subnet-3" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2"
  tags = {
    Name = "db-subnet"
  }
}

# Create subnet 4
resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2"
  tags = {
    Name = "prod-subnet"
  }
}

# Associate subnet 1 with route table
resource "aws_route_table_association" "1" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.main-route-table.id
}

# Associate subnet 2 with route table
resource "aws_route_table_association" "2" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.main-route-table.id
}

# Associate subnet 3 with route table
resource "aws_route_table_association" "3" {
  subnet_id      = aws_subnet.subnet-3.id
  route_table_id = aws_route_table.main-route-table.id
}

# Associate subnet 4 with route table
resource "aws_route_table_association" "4" {
  subnet_id      = aws_subnet.subnet-4.id
  route_table_id = aws_route_table.main-route-table.id
}

# Create jenkins security group. Each IP will need an ingress rule of its own
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Allow SSH, HTTP traffic and traffic through port 8080 for specific IPs of development team"
  vpc_id      = aws_vpc.main-vpc.id

  # Ingress/inbound rules

  # SSH Rules
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Daood IP goes here. /32 CIDR notation for single IP
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Adama IP goes here. /32 CIDR notation for single IP
  }

  # HTTP Rules
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Daood IP goes here. /32 CIDR notation for single IP
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Adama IP goes here. /32 CIDR notation for single IP
  }

  # Port 8080 Rules
  ingress {
    description = "port-8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Daood IP goes here. /32 CIDR notation for single IP
  }

  ingress {
    description = "port-8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Adama IP goes here. /32 CIDR notation for single IP
  }

  # Egress/Outbound rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_access_jenkins_server"
  }
}

# Create test server security group
resource "aws_security_group" "test-sg" {
  name        = "test-sg"
  description = "Allow SSH and HTTP traffic for specific IPs of development team"
  vpc_id      = aws_vpc.main-vpc.id

  # Ingress/inbound rules

  # SSH Rules
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Daood IP goes here. /32 CIDR notation for single IP
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Adama IP goes here. /32 CIDR notation for single IP
  }

  # HTTP Rules
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Daood IP goes here. /32 CIDR notation for single IP
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Adama IP goes here. /32 CIDR notation for single IP
  }

  # Egress/Outbound rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_access_test_server"
  }
}

resource "aws_security_group" "prod-sg" {
  name        = "prod-sg"
  description = "Allow SSH and HTTP traffic for specific IPs of development team"
  vpc_id      = aws_vpc.main-vpc.id

  # Ingress/inbound rules

  # SSH Rules
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Daood IP goes here. /32 CIDR notation for single IP
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Adama IP goes here. /32 CIDR notation for single IP
  }

  # HTTP Rules
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Daood IP goes here. /32 CIDR notation for single IP
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Adama IP goes here. /32 CIDR notation for single IP
  }

  # Egress/Outbound rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_access_prod_server"
  }
}

resource "aws_security_group" "database-sg" {
  name        = "database-sg"
  description = "Allow access from test and production subnets"
  vpc_id      = aws_vpc.main-vpc.id

  # Ingress/inbound rules

  # SSH Rules
  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Test subnet IP
  }

  ingress {
    description = "SSH"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"] #Prod subnet IP
  }
  
  # Egress/Outbound rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_access_db_subnet"
  }
}