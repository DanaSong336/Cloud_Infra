terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "main_vpc"
}

module "subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id

  subnets = {
    public_subnet_1 = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "ap-northeast-2a"
      map_public_ip     = true
      name              = "public_subnet_1"
    },
    public_subnet_2 = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "ap-northeast-2c"
      map_public_ip     = true
      name              = "public_subnet_2"
    },
    private_subnet_1 = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "ap-northeast-2a"
      map_public_ip     = false
      name              = "private_subnet_1"
    },
    private_subnet_2 = {
      cidr_block        = "10.0.4.0/24"
      availability_zone = "ap-northeast-2c"
      map_public_ip     = false
      name              = "private_subnet_2"
    }
  }
}


module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
  name   = "main_igw"
}

module "rt" {
  source             = "./modules/rt"
  vpc_id             = module.vpc.vpc_id
  cidr_block         = "0.0.0.0/0"
  igw_id             = module.igw.igw_id
  name               = "public_rt"
  public_subnet_1_id = module.subnet.subnet_ids[0]
  public_subnet_2_id = module.subnet.subnet_ids[1]
}

module "sg_lb" {
  source = "./modules/sg"

  vpc_id = module.vpc.vpc_id

  security_groups = {
    lb_sg = {
      name = "LoadBalancerSG"
      ingress = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}

module "sg_web" {
  source = "./modules/sg"

  vpc_id = module.vpc.vpc_id

  security_groups = {
    web_sg = {
      name = "WebServerSG"
      ingress = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }

}
module "sg_rds" {
  source = "./modules/sg"

  vpc_id = module.vpc.vpc_id

  security_groups = {
    rds_sg = {
      name = "RDS-SG"
      ingress = [
        {
          from_port       = 3306
          to_port         = 3306
          protocol        = "tcp"
          security_groups = [module.sg_web.sg_ids["web_sg"]] # EC2 보안 그룹 참조
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }

}

module "iam" {
  source        = "./modules/iam"
  name          = "s3_access_policy"
  description   = "Policy to allow access to S3 bucket"
  s3_bucket_arn = module.s3.web_bucket_arn
  profile_name  = "ec2_instance_profile"
}

module "lt" {
  source               = "./modules/lt"
  name                 = "web-launch-configuration"
  ami                  = "ami-05d2438ca66594916"
  instance_type        = "t3.micro"
  key_name             = "CICD"
  security_group_ids   = [module.sg_web.sg_ids["web_sg"]]
  iam_instance_profile = module.iam.ec2_instance_profile
  user_data            = base64encode(file("./script/user_data_script.sh"))

  public_subnet_id = module.subnet.subnet_ids[0]
}

module "autoscaling" {
  source            = "./modules/autoscaling"
  lt_id             = module.lt.web_lt_id
  min_size          = 2
  max_size          = 4
  desired_capacity  = 2
  public_subnet_ids = [module.subnet.subnet_ids[0], module.subnet.subnet_ids[1]]
  health_check_type = "EC2"
  key               = "Name"
  value             = "WebServer"
  target_group_arns = [module.lb.app_tg_arn]
}

module "lb" {
  source             = "./modules/lb"
  name               = "app-lb"
  type               = "application"
  security_group_ids = [module.sg_lb.sg_ids["lb_sg"]]
  public_subnet_ids  = [module.subnet.subnet_ids[0], module.subnet.subnet_ids[1]]
  tag                = "AppLB"
  tg_name            = "app-tg"
  tg_port            = 80
  tg_protocol        = "HTTP"
  vpc_id             = module.vpc.vpc_id
  tg_tag             = "AppTG"
}

module "s3" {
  source = "./modules/s3"
  name   = "my-web-bucket-terraform-danbi"
  tag    = "MyWebBucket"
}

module "rds" {
  source                 = "./modules/rds"
  sg_name                = "rds-subnet-group"
  private_subnet_ids     = [module.subnet.subnet_ids[2], module.subnet.subnet_ids[3]]
  storage                = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  class                  = "db.t3.micro"
  db_name                = "mydatabase"
  username               = "admin"
  password               = "12345678"
  parameter_group_name   = "default.mysql8.0"
  vpc_security_group_ids = [module.sg_rds.sg_ids["rds_sg"]]
  tag                    = "rds-mysql"
}

module "cloudwatch" {
  source          = "./modules/cloudwatch"
  log_group_name  = "/aws/ec2/web_instance_logs"
  log_stream_name = "web_instance_log_stream"

  alarm_name          = "ASG-Capacity-Alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "GroupDesiredCapacity"
  namespace           = "AWS/AutoScaling"
  period              = "60"
  statistic           = "Average"
  threshold           = "2"
  description         = "This alarm triggers when the desired capacity of the Auto Scaling group falls below 2."
  asg_name            = module.autoscaling.web_asg_name

  alarm_name_rds          = "RDS-CPU-Utilization-Alarm"
  comparison_operator_rds = "GreaterThanThreshold"
  evaluation_periods_rds  = "2"
  metric_name_rds         = "CPUUtilization"
  namespace_rds           = "AWS/RDS"
  period_rds              = "60"
  statistic_rds           = "Average"
  threshold_rds           = "80"
  description_rds         = "This alarm triggers when the RDS CPU utilization exceeds 80%."
  rds_mysql_id            = module.rds.rds_mysql_id
}