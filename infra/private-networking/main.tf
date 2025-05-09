## -------------------------------------------------------------------------------------------------------------------
## PRIVATE-NETWORKING
## -------------------------------------------------------------------------------------------------------------------
## -------------------------------------------------------------------------------------------------------------------

## -------------------------------------------------------------------------------------------------------------------
## Terraform settings & provider configurations
## -------------------------------------------------------------------------------------------------------------------
##
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }
}

provider "aws" {
  alias = "private_networking"
}

## -------------------------------------------------------------------------------------------------------------------
## Variables
## -------------------------------------------------------------------------------------------------------------------
##
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24" # Small CIDR with 256 IPs
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/26" # 64 IPs
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.0.64/26" # 64 IPs
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Terraform = "true"
    Project   = "ghost-in-the-cloud"
  }
}

## -------------------------------------------------------------------------------------------------------------------
## VPC and Networking Resources
## -------------------------------------------------------------------------------------------------------------------
##

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = merge(
    var.tags,
    {
      Name = "ghost-vpc"
    }
  )
}

# Get available AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  
  tags = merge(
    var.tags,
    {
      Name = "ghost-public-subnet"
    }
  )
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  
  tags = merge(
    var.tags,
    {
      Name = "ghost-private-subnet"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    var.tags,
    {
      Name = "ghost-igw"
    }
  )
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = merge(
    var.tags,
    {
      Name = "ghost-public-rt"
    }
  )
}

# Route Table for Private Subnet (no internet access)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  # No routes to internet
  tags = merge(
    var.tags,
    {
      Name = "ghost-private-rt"
    }
  )
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security Group that allows all outgoing traffic but blocks incoming traffic
resource "aws_security_group" "outbound_only" {
  name        = "outbound-only"
  description = "Allow all outbound traffic, block all inbound traffic"
  vpc_id      = aws_vpc.main.id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  # No ingress rules means all inbound traffic is blocked
  
  tags = merge(
    var.tags,
    {
      Name = "ghost-outbound-only-sg"
    }
  )
}

