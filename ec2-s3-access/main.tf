provider "aws" {
  region = "ap-south-1"
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy to allow S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_read_only"
  description = "Allow EC2 to read from S3"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        "arn:aws:s3:::terraform-state-sai-skreddy-20250806",
        "arn:aws:s3:::terraform-state-sai-skreddy-20250806/*"
      ]
    }]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Launch EC2 instance
resource "aws_instance" "chatbot_ec2" {
  ami           = "ami-0861f4e788f5069dd" # Amazon Linux 2 AMI (replace if needed)
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "ChatbotEC2"
  }

  # Add key_name if you want SSH access
  # key_name = "your-key-pair-name"
}
