# AWS Infrastructure Deployment Guide

Complete step-by-step guide for deploying AWS infrastructure using Ansible.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [AWS Account Setup](#aws-account-setup)
3. [Local Environment Setup](#local-environment-setup)
4. [Configuration](#configuration)
5. [Deployment](#deployment)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

- Python 3.6 or higher
- Ansible 2.9 or higher
- AWS CLI version 2
- Git
- Text editor

### AWS Account Requirements

- Active AWS account
- Credit card on file
- Email verification completed
- Phone verification completed

## AWS Account Setup

### Step 1: Create IAM User

1. Log in to AWS Console
2. Navigate to IAM → Users
3. Click "Add User"
4. Username: `ansible-automation`
5. Access type: ✓ Programmatic access
6. Click "Next: Permissions"

### Step 2: Attach Policies

Attach the following managed policies:

- AmazonEC2FullAccess
- AmazonRDSFullAccess
- AmazonS3FullAccess
- ElasticLoadBalancingFullAccess
- AmazonVPCFullAccess

Or create custom policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "rds:*",
        "s3:*",
        "elasticloadbalancing:*",
        "iam:PassRole",
        "iam:CreateServiceLinkedRole"
      ],
      "Resource": "*"
    }
  ]
}
```

### Step 3: Save Credentials

1. Download credentials CSV
2. Save Access Key ID and Secret Access Key
3. **NEVER commit these to Git!**

## Local Environment Setup

### Step 1: Install Python and pip

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip -y

# macOS
brew install python3

# Verify installation
python3 --version
pip3 --version
```

### Step 2: Install Ansible

```bash
# Ubuntu/Debian
sudo apt install ansible -y

# macOS
brew install ansible

# Using pip
pip3 install ansible

# Verify installation
ansible --version
```

### Step 3: Install AWS CLI

```bash
# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# macOS
brew install awscli

# Verify installation
aws --version
```

### Step 4: Configure AWS CLI

```bash
aws configure
```

Enter when prompted:
- AWS Access Key ID: [Your Access Key]
- AWS Secret Access Key: [Your Secret Key]
- Default region name: us-east-1
- Default output format: json

Verify configuration:

```bash
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/ansible-automation"
}
```

### Step 5: Install Python Dependencies

```bash
pip3 install boto3 botocore
```

### Step 6: Install Ansible Collections

```bash
ansible-galaxy collection install amazon.aws
ansible-galaxy collection install community.aws
```

## Configuration

### Step 1: Clone Repository

```bash
git clone git@github.com:George-Nyamao/ansible-aws-infrastructure.git
cd ansible-aws-infrastructure
```

### Step 2: Review Default Configuration

View `group_vars/all.yml`:

```bash
cat group_vars/all.yml
```

### Step 3: Customize Configuration

Edit configuration:

```bash
vim group_vars/all.yml
```

Key settings to modify:

```yaml
project_name: "myproject"          # Your project name
environment: "production"           # Environment (dev/staging/prod)
aws_region: "us-east-1"            # AWS region
ec2_instance_type: "t3.micro"      # Instance type
rds_master_password: "SecurePass123!"  # Database password
```

### Step 4: Validate Configuration

```bash
# Check syntax
ansible-playbook site.yml --syntax-check

# Dry run
ansible-playbook site.yml --check
```

## Deployment

### Step 1: Deploy VPC

```bash
ansible-playbook site.yml --tags vpc
```

Expected output:
```
TASK [aws-vpc : Create VPC] ****
ok: [localhost]

TASK [aws-vpc : Create Internet Gateway] ****
ok: [localhost]
...
```

Verify VPC creation:

```bash
cat vpc_info.txt
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=myproject-production-vpc"
```

### Step 2: Deploy Security Groups

```bash
ansible-playbook site.yml --tags security
```

Verify security groups:

```bash
cat security_groups.txt
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=myproject"
```

### Step 3: Deploy EC2 Instances

```bash
ansible-playbook site.yml --tags ec2
```

This will:
- Create SSH key pair
- Launch EC2 instances
- Assign public IPs
- Wait for instances to be running

Verify EC2 instances:

```bash
cat ec2_instances.txt
aws ec2 describe-instances --filters "Name=tag:Project,Values=myproject"
```

### Step 4: Deploy RDS Database

```bash
ansible-playbook site.yml --tags rds
```

**Note**: RDS deployment takes 10-15 minutes.

Verify RDS instance:

```bash
cat rds_info.txt
aws rds describe-db-instances --db-instance-identifier myproject-production-db
```

### Step 5: Deploy S3 Bucket

```bash
ansible-playbook site.yml --tags s3
```

Verify S3 bucket:

```bash
cat s3_info.txt
aws s3 ls | grep myproject
```

### Step 6: Deploy Load Balancer

```bash
ansible-playbook site.yml --tags elb
```

Verify load balancer:

```bash
cat elb_info.txt
aws elbv2 describe-load-balancers --names myproject-production-elb
```

### Step 7: Full Deployment (All Components)

```bash
make deploy
# or
ansible-playbook site.yml
```

## Verification

### Check
# Complete DEPLOYMENT.md (continuing from where it cut off)
cat >> DEPLOYMENT.md << 'EOF'
 Infrastructure Status

```bash
make status
```

### Access EC2 Instances

```bash
# Get instance public IP from output file
cat ec2_instances.txt

# SSH into instance
ssh -i myproject-key.pem ec2-user@<PUBLIC_IP>

# If permission denied, fix key permissions
chmod 400 myproject-key.pem
```

### Test Load Balancer

```bash
# Get ALB DNS name
cat elb_info.txt

# Test HTTP endpoint
curl http://<ALB_DNS_NAME>

# Or open in browser
open http://<ALB_DNS_NAME>
```

### Test RDS Connection

```bash
# From EC2 instance
mysql -h <RDS_ENDPOINT> -u admin -p

# Test connection
SHOW DATABASES;
```

### Verify S3 Bucket

```bash
# List buckets
aws s3 ls

# Upload test file
echo "test" > test.txt
aws s3 cp test.txt s3://myproject-production-bucket/

# List bucket contents
aws s3 ls s3://myproject-production-bucket/
```

### Check All Resources

```bash
# VPC
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=myproject"

# Subnets
aws ec2 describe-subnets --filters "Name=tag:Project,Values=myproject"

# Security Groups
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=myproject"

# EC2 Instances
aws ec2 describe-instances --filters "Name=tag:Project,Values=myproject"

# RDS
aws rds describe-db-instances

# S3
aws s3 ls | grep myproject

# Load Balancer
aws elbv2 describe-load-balancers
```

## Troubleshooting

### Issue: Authentication Failure

**Error**: `Unable to locate credentials`

**Solution**:

```bash
# Check AWS credentials
aws configure list

# Reconfigure
aws configure

# Set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### Issue: VPC Limit Exceeded

**Error**: `VpcLimitExceeded: The maximum number of VPCs has been reached`

**Solution**:

```bash
# Check current VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]' --output table

# Delete unused VPCs
aws ec2 delete-vpc --vpc-id vpc-xxxxx

# Or request limit increase
aws service-quotas request-service-quota-increase \
  --service-code vpc \
  --quota-code L-F678F1CE \
  --desired-value 10
```

### Issue: Insufficient IAM Permissions

**Error**: `User: arn:aws:iam::xxx:user/xxx is not authorized to perform: ec2:CreateVpc`

**Solution**:

1. Log in to AWS Console
2. Navigate to IAM → Users
3. Select your user
4. Add required permissions (see IAM policy in setup)

### Issue: Instance Launch Failed

**Error**: `Instance capacity not available`

**Solution**:

```bash
# Try different instance type
ansible-playbook site.yml -e "ec2_instance_type=t3.small"

# Try different availability zone
ansible-playbook site.yml -e "aws_availability_zones=['us-east-1c','us-east-1d']"
```

### Issue: RDS Creation Timeout

**Error**: `Timeout waiting for RDS instance`

**Solution**:

RDS creation can take 15-20 minutes. Wait and check status:

```bash
# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier myproject-production-db \
  --query 'DBInstances[0].DBInstanceStatus'

# Wait for 'available' status
```

### Issue: S3 Bucket Name Already Exists

**Error**: `BucketAlreadyExists: The requested bucket name is not available`

**Solution**:

S3 bucket names are globally unique. Change bucket name:

```bash
ansible-playbook site.yml -e "s3_bucket_name=myproject-prod-bucket-$(date +%s)"
```

### Issue: Load Balancer Creation Failed

**Error**: `A load balancer cannot be attached to multiple subnets in the same Availability Zone`

**Solution**:

Ensure subnets are in different AZs:

```yaml
# group_vars/all.yml
aws_availability_zones:
  - "us-east-1a"
  - "us-east-1b"  # Different AZ
```

### Issue: SSH Connection Refused

**Error**: `ssh: connect to host x.x.x.x port 22: Connection refused`

**Solution**:

```bash
# Check instance is running
aws ec2 describe-instance-status --instance-id <INSTANCE_ID>

# Check security group allows SSH
aws ec2 describe-security-groups --group-id <SG_ID>

# Wait for instance initialization (2-3 minutes)
aws ec2 wait instance-status-ok --instance-id <INSTANCE_ID>
```

### Debug Mode

Run playbook with verbose output:

```bash
# Basic verbose
ansible-playbook site.yml -v

# More verbose
ansible-playbook site.yml -vv

# Maximum verbose
ansible-playbook site.yml -vvv
```

### Check Logs

```bash
# Ansible log
cat ansible.log

# AWS CloudTrail (if enabled)
aws cloudtrail lookup-events --max-results 10
```

## Post-Deployment

### Configure Application

1. **SSH into EC2 instance**:

```bash
ssh -i myproject-key.pem ec2-user@<PUBLIC_IP>
```

2. **Install application dependencies**:

```bash
# Update system
sudo yum update -y

# Install web server
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd

# Deploy application
sudo vim /var/www/html/index.html
```

3. **Configure database connection**:

```bash
# Get RDS endpoint
cat rds_info.txt

# Configure application
vim /path/to/config.php
```

### Set Up Monitoring

```bash
# Enable CloudWatch detailed monitoring
aws ec2 monitor-instances --instance-ids <INSTANCE_ID>

# Create CloudWatch alarm
aws cloudwatch put-metric-alarm \
  --alarm-name high-cpu \
  --alarm-description "Alert when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value=<INSTANCE_ID> \
  --evaluation-periods 2
```

### Configure Backups

```bash
# Enable RDS automated backups (already configured)
aws rds modify-db-instance \
  --db-instance-identifier myproject-production-db \
  --backup-retention-period 7 \
  --preferred-backup-window "03:00-04:00"

# Create S3 lifecycle policy (already configured)
# Objects transition to Glacier after 30 days
```

### Set Up SSL/TLS

1. **Request ACM Certificate**:

```bash
aws acm request-certificate \
  --domain-name example.com \
  --validation-method DNS \
  --subject-alternative-names "*.example.com"
```

2. **Update ALB Listener**:

```bash
# Add HTTPS listener
aws elbv2 create-listener \
  --load-balancer-arn <ALB_ARN> \
  --protocol HTTPS \
  --port 443 \
  --certificates CertificateArn=<CERT_ARN> \
  --default-actions Type=forward,TargetGroupArn=<TG_ARN>
```

### Configure DNS

1. **Create Route53 hosted zone** (if using Route53):

```bash
aws route53 create-hosted-zone \
  --name example.com \
  --caller-reference $(date +%s)
```

2. **Create A record pointing to ALB**:

```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id <ZONE_ID> \
  --change-batch file://record.json
```

```json
{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "example.com",
      "Type": "A",
      "AliasTarget": {
        "HostedZoneId": "<ALB_ZONE_ID>",
        "DNSName": "<ALB_DNS_NAME>",
        "EvaluateTargetHealth": false
      }
    }
  }]
}
```

## Maintenance

### Update Infrastructure

```bash
# Modify configuration
vim group_vars/all.yml

# Apply changes
ansible-playbook site.yml
```

### Scale Resources

```bash
# Add more EC2 instances
ansible-playbook site.yml -e "ec2_instance_count=4"

# Change instance type
ansible-playbook site.yml -e "ec2_instance_type=t3.medium"

# Upgrade RDS
ansible-playbook site.yml -e "rds_instance_class=db.t3.small"
```

### Backup and Recovery

```bash
# Manual RDS snapshot
aws rds create-db-snapshot \
  --db-instance-identifier myproject-production-db \
  --db-snapshot-identifier manual-backup-$(date +%Y%m%d)

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier myproject-restored \
  --db-snapshot-identifier manual-backup-20240115

# Backup S3 data
aws s3 sync s3://myproject-production-bucket ./s3-backup/

# Restore S3 data
aws s3 sync ./s3-backup/ s3://myproject-production-bucket/
```

### Clean Up / Destroy

```bash
# Destroy all resources
make destroy

# Or
ansible-playbook destroy.yml
```

**⚠️ WARNING**: This permanently deletes:
- All EC2 instances
- RDS database (no final snapshot by default)
- S3 bucket and contents
- Load balancer
- VPC and networking components

## Cost Management

### Monitor Costs

```bash
# Check current month costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

### Set Billing Alerts

1. Enable billing alerts in AWS Console
2. Create CloudWatch alarm:

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name billing-alert \
  --alarm-description "Alert when costs exceed $100" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 21600 \
  --threshold 100 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1
```

### Optimize Costs

1. **Use Reserved Instances**: Save 30-75%
2. **Enable Auto Scaling**: Scale down during off-hours
3. **Use Spot Instances**: Save up to 90% for non-critical workloads
4. **Right-size Instances**: Monitor and adjust
5. **Delete Unused Resources**: Regular audits
6. **Use S3 Lifecycle Policies**: Move old data to cheaper storage

## Security Checklist

- [ ] AWS account MFA enabled
- [ ] IAM user follows least privilege
- [ ] Security groups restrict access
- [ ] RDS in private subnet
- [ ] RDS encryption enabled
- [ ] S3 encryption enabled
- [ ] S3 public access blocked
- [ ] CloudTrail enabled
- [ ] VPC Flow Logs enabled
- [ ] Regular security audits
- [ ] Automated backups configured
- [ ] SSL/TLS certificates deployed
- [ ] Secrets in AWS Secrets Manager
- [ ] Regular patching schedule

## Best Practices

### Infrastructure as Code
- Version control all configurations
- Use meaningful git commit messages
- Tag releases
- Document changes

### Security
- Never commit credentials
- Use IAM roles where possible
- Enable MFA
- Regular security audits
- Principle of least privilege

### High Availability
- Multi-AZ deployments
- Auto Scaling groups
- Health checks
- Automated failover

### Monitoring
- CloudWatch metrics
- Log aggregation
- Alerting setup
- Regular reviews

### Cost Optimization
- Regular audits
- Reserved instances
- Auto Scaling
- Lifecycle policies

## Additional Resources

### AWS Documentation
- [VPC User Guide](https://docs.aws.amazon.com/vpc/)
- [EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [RDS User Guide](https://docs.aws.amazon.com/rds/)
- [ELB User Guide](https://docs.aws.amazon.com/elasticloadbalancing/)

### Ansible Documentation
- [Amazon AWS Collection](https://docs.ansible.com/ansible/latest/collections/amazon/aws/)
- [Community AWS Collection](https://docs.ansible.com/ansible/latest/collections/community/aws/)

### Tools
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)
- [AWS Calculator](https://calculator.aws/)
- [AWS Well-Architected Tool](https://aws.amazon.com/well-architected-tool/)

## Support

For issues or questions:
- GitHub Issues: https://github.com/yourusername/ansible-aws-infrastructure/issues
- AWS Support: https://console.aws.amazon.com/support/
- Ansible Community: https://www.ansible.com/community

---

**Document Version**: 1.0.0  
**Last Updated**: 2024-01-XX  
**Author**: Your Name
